require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'nice_json_api'

require 'minitest/autorun'
require 'webmock/minitest'
