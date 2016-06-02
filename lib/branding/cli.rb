require 'optparse'
require 'ostruct'

module Branding
  class CLI
    def initialize(args)
      @options = OpenStruct.new

      @options.file = args.last

      @parser = OptionParser.new do |opts|
        opts.banner = 'Usage: branding FILE'
        opts.on('-p PIXEL',
                '--pixel=PIXEL',
                [:normal, :hires, :hicolor],
                'The pixel rendering algorithm (`normal`, `hires`, or `hicolor`)') do |pixel_algo|
          @options.algo = pixel_algo.to_sym
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit
        end
      end

      @parser.parse!(args)
      @options
    end

    def run
      logo = Branding::Logo.new(@options.file)
      logo.algo = @options.algo if @options.algo
      logo.print
    end
  end
end
