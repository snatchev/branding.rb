module Branding
  class Logo # :nodoc:
    attr_accessor :algo

    def initialize(path)
      @algo = :normal
      @img = PNG.from_file(path)
      @canvas = Canvas.new(width: @img.width, height: @img.height)
    end

    def print
      @canvas.load(@img.pixels, algo: @algo)
      @canvas.print
      nil
    end
  end
end
