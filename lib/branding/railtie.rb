module Branding
  class Railtie < Rails::Railtie

    unless Rails.env.production?
      initializer('branding.print_logo') do
        logo = Branding::Logo.new(Branding::Railtie.favicons)
        logo.print
      end
    end

    ##
    # find the best suited icon in a rails app
    def self.favicons
      paths = ["#{Rails.root}/public/", "#{Rails.root}/app/assets/images/"]
      file_patterns = ['favicon*.png', 'apple-touch-icon*.png']
      patterns = paths.product(file_patterns).map(&:join)

      matches = Dir.glob(patterns)

      matches.sort_by{|path| File.stat(path).size }.first
    end
  end
end
