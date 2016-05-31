module Branding
  class Logo
    def initialize(path)
      @img = PNG.from_file(path)
      @canvas = Canvas.new(width: @img.width, height: @img.height)
    end

    def print
      @canvas.load(@img.pixels)
      @canvas.print
      nil
    end
  end
end
