require 'branding/ansi'

module Branding
  class Canvas
    attr_reader :width, :height, :rows, :cols

    def self.terminal_size
      # TODO: make sure we can get this on linux
      begin
        `stty size`.split.map(&:to_i)
      rescue
        [40, 100]
      end
    end

    def initialize(width:, height:)
      @width, @height = width, height
      @rows, @cols = self.class.terminal_size
      @pixel_buffer = []
    end

    def load(pixels, algo: :normal)
      case algo
      when :normal
        klass = Pixel
      when :hires
        klass = Pixel2x
      when :hicolor
        raise 'Hi-Color coming soon!'
      else
        raise "Unknown pixel algo `#{algo}`"
      end

      klass.load_strategy(pixels, width: width, height: height) do |pixel|
        @pixel_buffer << pixel
      end
    end

    def print
      @pixel_buffer.each_with_index do |pixel, idx|
        if (idx % width * pixel.width) >= cols
          next
        end

        if idx % max_width == 0
          STDOUT.puts(ANSI.reset)
        end

        STDOUT.print(pixel)
      end
    end

    def max_width
      @max_width ||= [@width, @cols].min
    end
  end
end
