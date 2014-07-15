require 'rspec'
require 'coveralls'
require 'simplecov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter '/spec/'
end

begin
  require "debugger"
rescue LoadError
  # most probably using 1.8
  require "ruby-debug"
end

require File.expand_path('../../lib/leankit_download', __FILE__)