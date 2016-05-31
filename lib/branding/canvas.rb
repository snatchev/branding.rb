require 'branding/ansi'

module Branding
  class Canvas
    attr_reader :width, :height, :rows, :cols

    def initialize(width:,height:)
      @width, @height = width, height
      @rows, @cols = `stty size`.split.map { |x| x.to_i }
      @pixel_buffer = []
    end

    def load(pixels)
      Pixel.load_strategy(pixels, width: width, height: height) do |pixel|
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
