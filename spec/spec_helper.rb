require 'rubygems'
require 'spec'
require 'mocha'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[.. lib]))
require 'mimic'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
