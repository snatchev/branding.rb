# encoding: UTF-8
module Branding
  class Pixel
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

  class Pixel2x < Pixel

    def initialize(doublepix)
      @top, @bot = doublepix
    end

    ##
    # "  "
    # "▀ "
    # "▀▀"
    # "▀█"
    # "  " <- fg color
    # "█ "
    # "▄█"
    # "▄▄"
    # "▄ "
    def to_s
      if @top == @bot
        return "#{ANSI.bg(*ANSI.uint32_to_rgb(@top))} "
      end

      "#{ANSI.fg(*ANSI.uint32_to_rgb(@bot))}#{ANSI.bg(*ANSI.uint32_to_rgb(@top))}▄"
    end
  end
end
