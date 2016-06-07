require 'rubygems'
require 'rspec'
require 'mocha'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[.. lib]))
require 'mimic'
require 'rspec/expectations'

RSpec.configure do |config|
  config.mock_with :mocha
end
