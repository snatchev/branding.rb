# encoding: UTF-8
require 'matrix'

module Branding
  ##
  #
  #
  class Pixel
    def self.load_strategy(pixels, height:, width:)
      pixels.each do |pixel_value|
        yield self.new(pixel_value)
      end
    end

    def self.rgb(r,g,b)
      self.new((r << 24) | (g << 16) | b << 8)
    end

    attr_accessor :uint32

    ##
    # basic 2-space with background color per pixel
    def initialize(*opts)
      opts = opts.first if opts.size == 1

      case opts
      when self.class
        @uint32 = opts.uint32
      when Fixnum
        @uint32 = opts
      when Array
        r,g,b,a = opts
        a ||= 0xff # alpha is optional. If it is not supplied, assume full-alpha.
        @uint32 = (r << 24) | (g << 16) | b << 8 | a
      when Hash
        #(r << 24) | (g << 16) | b << 8)
      else
        raise "Cannot initialize Pixel with #{opts.inspect}."
      end
    end

    def inspect
      "0x%0.8x" % @uint32
    end

    def ==(value)
      case value
      when self.class
        @uint32 == value.uint32
      when Fixnum
        @uint32 == value
      else
        @uint32 == value
      end
    end

    def to_i
      uint32
    end

    def r
      @uint32 & 0xff000000
    end

    def g
      @uint32 & 0x00ff0000
    end

    def b
      @uint32 & 0x0000ff00
    end

    def a
      @uint32 & 0x000000ff
    end

    def to_rgb
      {r: r, g: g, b: b}
    end

    def to_rgba
      {r: r, g: g, b: b, a: a}
    end

    def to_s
      "#{ANSI.bg(*ANSI.uint32_to_rgb(@uint32))}  "
    end

    def width
      2
    end
  end

  class PixelHiColor < Pixel
    def to_s
      "#{ANSI.bg(*ANSI.uint32_to_rgb(@uint32))}  "
    end
  end

  class Pixel2x < Pixel

    def self.load_strategy(pixels, height:, width:)
      matrix = Matrix.build(height, width) do |row, col|
        pixels[col + row*width]
      end

      (0..height).step(2) do |row|
        matrix.minor(row, 2, 0, width).transpose.to_a.each do |top, bottom|
          yield self.new(top.to_i, bottom.to_i)
        end
      end
    end

    def initialize(top, bottom)
      @top, @bot = top, bottom

      @top ||= 0x000000ff
      @bot ||= 0x000000ff
    end

    def width
      1
    end

    def to_s
      if ANSI.clamped(@top) == ANSI.clamped(@bot)
        return "#{ANSI.bg(*ANSI.uint32_to_rgb(@top))} "
      end

      "#{ANSI.fg(*ANSI.uint32_to_rgb(@bot))}#{ANSI.bg(*ANSI.uint32_to_rgb(@top))}▄"
    end
  end
end
