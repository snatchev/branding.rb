require 'optparse'
require 'ostruct'

module Branding
  class CLI
    def initialize(args)
      @options = OpenStruct.new

      @options.command = :print_logo
      @options.file = args.last

      @parser = OptionParser.new do |opts|
        opts.banner = 'Usage: branding FILE'
        opts.on('-a') do |algo|
          @options = algo
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
      send(@options.command)
    end

    def print_logo
      logo = Branding::Logo.new(@options.file)
      logo.print
    end
  end
end
