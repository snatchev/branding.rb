module Branding
  ##
  # heavily borrowed and stripped down from ChunkyPNG
  class PNG
    SIGNATURE = [137, 80, 78, 71, 13, 10, 26, 10].pack('C8').force_encoding('BINARY')

    attr_reader :width, :height, :depth, :color, :compression, :filtering, :interlace

    class Imagedata
      include Enumerable

      def initialize(data)
        zstream = Zlib::Inflate.new
        data.each {|d| zstream << d }
        @inflated = zstream.finish
        zstream.close
      end

      def each
        idx = 0
        size = @inflated.bytesize
        @inflated.each_bytes
      end
    end

    def self.from_file(path)
      new(File.open(path, 'rb'))
    end

    def initialize(io)
      signature = io.read(SIGNATURE.length)
      raise 'Signature mismatch' unless signature == SIGNATURE

      @data = []

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

      unless @depth == 8
        raise NotImplementedError, 'only supporting 8bit color depth'
      end

      unless @color == 2
        raise NotImplementedError, 'only supporting true color, without alpha'
      end

      unless @filtering == 0
        raise NotImplementedError, 'does not supporting filtering'
      end

      unless @compression == 0
        raise NotImplementedError, 'only supporting deflate compression'
      end
    end

    def pixels
      imagedata = Imagedata.new(@data)
      imagedata.each_cons(3)
    end

    private

    def read_chunk(io)
      length, type = read_bytes(io, 8).unpack('Na4')

      content = read_bytes(io, length)
      crc     = read_bytes(io, 4).unpack('N').first
      verify_crc(type, content, crc)

      return type, content
    end

    def read_bytes(io, length)
      data = io.read(length)
    end

    def verify_crc(type, content, found_crc)
      expected_crc = Zlib.crc32(content, Zlib.crc32(type))
      raise "Chuck CRC mismatch!" if found_crc != expected_crc
    end
  end
end
