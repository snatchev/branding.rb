module Branding
  class Railtie < Rails::Railtie

    unless Rails.env.production?
      initializer('branding.print_logo') do
        begin
          rows, cols = Canvas.terminal_size
          ideal_width = cols / 6

          logo = Branding::Logo.new(Branding::Railtie.best_icon(ideal_width))
          logo.algo = :hires
          logo.print
          print "\n"
        rescue
          # We don't want to do anything if this causes an exception. Your time
          # is too valuable to be dealing with busted amusement gems.
        end
      end
    end

    ##
    # find the best suited icon in a rails app
    def self.best_icon(ideal_width)
      paths = icon_paths.sort_by do |path|
        png = PNG.from_file(path)
        (ideal_width - png.width).abs
      end

      if paths.empty?
      else
        paths.first
      end
    end

    def self.icon_paths
      paths = ["#{Rails.root}/public/", "#{Rails.root}/app/assets/images/"]
      file_patterns = ['favicon*.png', 'apple-touch-icon*.png']
      patterns = paths.product(file_patterns).map(&:join)
      Dir.glob(patterns)
    end
  end
end
