# encoding: UTF-8
require 'matrix'

module Branding
  class Pixel

    def self.load_strategy(pixels, height:, width:)
      pixels.each do |pixel_value|
        yield self.new(pixel_value)
      end
    end

    ##
    # basic 2-space with background color per pixel
    def initialize(uint32)
      @value = uint32
    end

    def to_s
      "#{ANSI.bg(*ANSI.uint32_to_rgb(@value))}  "
    end

    def width
      2
    end
  end

  class PixelHiColor < Pixel
    def to_s
      "#{ANSI.bg(*ANSI.uint32_to_rgb(@value))}  "
    end
  end

  class Pixel2x < Pixel

    def self.load_strategy(pixels, height:, width:)
      matrix = Matrix.build(height, width) do |row, col|
        pixels[col + row*width]
      end

      (0..height).step(2) do |row|
        matrix.minor(row, 2, 0, width).transpose.to_a.each do |doublepix|
          yield self.new(doublepix)
        end
      end
    end

    def initialize(doublepix)
      @top, @bot = doublepix
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
