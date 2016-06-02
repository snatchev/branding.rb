module Branding
  ##
  # This is a simple PNG decoder, inspired and adapted from ChunkyPNG
  class PNG
    SIGNATURE = [137, 80, 78, 71, 13, 10, 26, 10].pack('C8').force_encoding('BINARY')

    attr_reader :width, :height, :depth, :color, :compression, :filtering, :interlace

    ##
    # Private class for holding and deflating image data
    #
    class Imagedata
      include Enumerable

      def initialize(data:, scanline_width:, color_channels: )
        @scanline_width = scanline_width
        @color_channels = color_channels

        zstream = Zlib::Inflate.new
        zstream << data
        @inflated = zstream.finish
        zstream.close
      end

      ##
      # yields byte
      def each
        @inflated.each_byte do |byte|
          yield byte
        end
      end

      def each_scanline
        bytes_in_scanline = @scanline_width * @color_channels + 1 #the number of bytes is +1 because of the filter byte
        previous_scanline = nil

        each_slice(bytes_in_scanline) do |scanline|
          filter_bit, *rest = *scanline
          filter = Filter.new(filter_bit, rest, previous_scanline, @color_channels)

          recon = filter.reconstructed_scanline
          yield recon
          previous_scanline = recon
        end
      end

      def each_pixel
        each_scanline do |scanline|
          scanline.each_slice(@color_channels) do |*rgba|
            yield Pixel.new(*rgba)
          end
        end
      end
    end

    ##
    # private class to handle reconstructing filtered data
    # https://www.w3.org/TR/PNG/#9Filters
    class Filter
      ##
      #
      def initialize(filter_bit, filtered_scanline, previous_scanline, color_channels)
        @type = filter_bit
        @filtered = filtered_scanline
        @previous = previous_scanline || []
        @pixel_width = color_channels
        @position = 0
      end

      ##
      # yields a reconstructed byte
      def reconstructed_scanline
        @reconstructed_scanline = []
        @filtered.each do |byte|
          recon = case @type
          when 0
            none(byte)
          when 1
            sub(byte)
          when 2
            up(byte)
          when 3
            average(byte)
          when 4
            paeth(byte)
          end

          @reconstructed_scanline << (recon % 256)
          @position += 1
        end

        @reconstructed_scanline
      end

      # a: the byte corresponding to x in the pixel immediately before the pixel
      # containing x (or the byte immediately before x, when the bit depth is
      # less than 8)
      def a
        offset = @position - @pixel_width
        return 0x00 if offset < 0

        @reconstructed_scanline[offset]
      end

      def b
        @previous[@position] || 0x00
      end

      def c
        offset = @position - @pixel_width
        return 0x00 if offset < 0

        @previous[offset]
      end

      def none(x)
        x
      end

      def sub(x)
        x + a
      end

      def up(x)
        x + b
      end

      def average(x)
        x + ((a + b) / 2.0).floor
      end

      # https://www.w3.org/TR/PNG/#9Filter-type-4-Paeth
      def paeth(x)
        x + paeth_predictor(a,b,c)
      end

      def paeth_predictor(a,b,c)
        p = a + b - c
        pa = (p - a).abs
        pb = (p - b).abs
        pc = (p - c).abs

        return a if pa <= pb && pa <= pc

        return b if pb <= pc

        c
      end
    end

    def self.from_file(path)
      new(File.open(path, 'rb'))
    end

    def initialize(io)
      signature = io.read(SIGNATURE.length)
      raise 'Signature mismatch' unless signature == SIGNATURE

      @data = ''

      until io.eof?
        type, content = read_chunk(io)

        case type
        when 'IHDR'
          fields = content.unpack('NNC5')
          @width, @height, @depth, @color, @compression, @filtering, @interlace = fields

        when 'IDAT'
          @data << content
        end
      end

      unless depth == 8
        raise NotImplementedError, 'only supporting 8bit color depth'
      end

      unless color == 2 || color == 6
        raise NotImplementedError, 'only supporting true color, with or without alpha'
      end

      unless filtering == 0
        raise NotImplementedError, 'does not supporting filtering'
      end

      unless compression == 0
        raise NotImplementedError, 'only supporting deflate compression'
      end
    end

    def pixels
      if block_given?
        imagedata.each_pixel
      else
        imagedata.enum_for(:each_pixel).to_a
      end
    end

    ##
    # the number of color channels. Not the PNG "color mode"
    def color_channels
      color == 2 ? 3 : 4
    end

    private

    def imagedata
      Imagedata.new(data: @data, scanline_width: width, color_channels: color_channels)
    end

    def read_chunk(io)
      length, type = read_bytes(io, 8).unpack('Na4')

      content = read_bytes(io, length)
      crc     = read_bytes(io, 4).unpack('N').first
      verify_crc(type, content, crc)

      [type, content]
    end

    def read_bytes(io, length)
      data = io.read(length)

      if data.nil? || data.bytesize != length
        raise "Could not read #{length} bytes from io"
      end

      data
    end

    def verify_crc(type, content, found_crc)
      expected_crc = Zlib.crc32(content, Zlib.crc32(type))
      raise 'Chuck CRC mismatch!' if found_crc != expected_crc
    end
  end
end
