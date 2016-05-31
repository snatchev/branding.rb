$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'branding'

def fixture_file(path)
  File.join(File.expand_path('../fixtures', __FILE__), path)
end
