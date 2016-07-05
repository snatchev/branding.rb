module Branding
  class Railtie < Rails::Railtie
    unless Rails.env.production?
      initializer('branding.print_logo') do
        begin
          rows, cols = Canvas.terminal_size
          ideal_width = cols / 6

          if icon_path = Branding::Railtie.best_icon(ideal_width)
            logo = Branding::Logo.new(icon_path)
            logo.algo = :hires
            logo.print
            print "\n"
          end
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
        nil
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
