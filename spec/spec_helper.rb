require 'rspec'

begin
  require "debugger"
rescue LoadError
  # most probably using 1.8
  require "ruby-debug"
end

require File.expand_path('../../lib/leankit_download', __FILE__)