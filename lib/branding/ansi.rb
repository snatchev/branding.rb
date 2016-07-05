module Branding
  module ANSI
    ATTRS = (0..8).map { |i| "\e[#{i}m".to_sym }.freeze
    FGCOLORS = (0..256).map { |i| "\e[38;5;#{i}m".to_sym }.freeze
    BGCOLORS = (0..256).map { |i| "\e[48;5;#{i}m".to_sym }.freeze
    # 2580 - 259F
    SHADERS = [:"\u2591", :"\u2592", :"\u2593"].freeze

    module_function

    def fg(r, g, b)
      FGCOLORS[rgb_offset(r, g, b)]
    end

    def bg(r, g, b)
      BGCOLORS[rgb_offset(r, g, b)]
    end

    def reset
      ATTRS[0]
    end

    def clear
    end

    def up
    end

    def down
    end

    def left
    end

    def right
    end

    def save_cursor
      :"\e[s"
    end

    def restore_cursor
      :"\e[u"
    end

    # 0x10-0xE7:  6 × 6 × 6 = 216 colors
    def rgb_offset(r, g, b)
      16 + (36 * scale_color(r)) + (6 * scale_color(g)) + scale_color(b)
    end

    ##
    # scale an 8bit number to 0-5
    # 5*51==255
    def scale_color(uint8)
      (uint8 / 51.0).round
    end

    # we probably shouldn't be passing in non-ints
    def uint32_to_rgb(uint32)
      return [0, 0, 0] unless uint32.is_a?(Integer)

      r = (uint32 & 0xff000000) >> 24
      g = (uint32 & 0x00ff0000) >> 16
      b = (uint32 & 0x0000ff00) >> 8

      [r, g, b]
    end

    # we probably shouldn't be passing in non-ints
    def clamped(uint32)
      return [0, 0, 0] unless uint32.is_a?(Integer)

      r = (uint32 & 0xff000000) >> 24
      g = (uint32 & 0x00ff0000) >> 16
      b = (uint32 & 0x0000ff00) >> 8

      scale_color(r) & scale_color(g) & scale_color(b)
    end
  end
end
