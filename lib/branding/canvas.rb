require 'branding/ansi'
require 'matrix'

module Branding
  class Canvas
    attr_reader :width, :height, :cols

    def initialize(width:,height:)
      @width, @height = width, height
      @cols = `stty size`.split.map { |x| x.to_i }.last
      @pixel_buffer = []
    end

    def load(pixels)
      #for regular pixel
      #pixels.each do |pixel|
      #  self << pixel
      #end
      @matrix = Matrix.build(height, width) do |row, col|
        pixels[col + row*width]
      end

      (0..height).step(2) do |row|
        @matrix.minor(row,2,0,width).transpose.to_a.each do |block|
          @pixel_buffer << Pixel2x.new(block)
        end
      end
    end

    ##
    # pixel is a 32bit number.
    # eventually it can attempt to handle any kind of pixel

    def print
      @pixel_buffer.each_with_index do |pixel, idx|
        if (idx % width * pixel.width) >= cols
          next
        end

        if idx % max_width == 0
          STDOUT.print("#{ANSI.reset}\n")
        end

        STDOUT.print(pixel)
      end
    end

    def max_width
      @max_width ||= [@width, @cols].min
    end
  end
end
