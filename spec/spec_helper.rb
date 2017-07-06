require 'simplecov'
SimpleCov.start
if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'rspec'
require 'rspec/autorun'

require 'hashdiff'

RSpec.configure do |config|
  config.mock_framework = :rspec

  config.include RSpec::Matchers
end
