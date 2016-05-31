module Branding
  ##
  # This is an API wrapper around ChunkyPNG until this library implements its
  # own PNG decoding.
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
        idx = 0
#       bytes_in_scanline = @scanline_width * @color_channels

        @inflated.each_byte do |byte|
          # new scanline. Go to next one.
          #if idx % bytes_in_scanline == 0 && byte == 0x00
            #idx = 0
            #next
          #end
          yield byte
          idx += 1
        end
      end

      def each_pixel
        each_slice(@color_channels) do |r, g, b, a|
          yield Pixel.new(r,g,b,a)
        end
      end

      def each_scanline
        enum_for(:each_pixel).to_a.each_slice(@scanline_width)
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

    def headers
      {
        width: width,
        height: height,
        depth: depth,
        color: color,
        compression: compression,
        filtering: filtering,
        interlace: interlace
      }
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
