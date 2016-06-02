# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'branding/version'

Gem::Specification.new do |spec|
  spec.name          = 'branding'
  spec.version       = Branding::VERSION
  spec.authors       = ['Stefan Natchev']
  spec.email         = ['stefan.natchev@gmail.com']
  spec.summary       = 'Print your logo to the terminal.'
  spec.description   = 'Proud of your work? Add some branding bling with Branding.rb'
  spec.homepage      = 'https://github.com/snatchev/branding.rb'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.40'
end
