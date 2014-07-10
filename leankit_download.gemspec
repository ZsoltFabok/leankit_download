# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'leankit_download/version'

Gem::Specification.new do |s|
  s.name        = 'leankit_download'
  s.version     = LeankitDownload::VERSION
  s.date        = '2014-01-15'
  s.summary     = "leankit_download-#{s.version}"
  s.description = "downloads data from leankit"
  s.authors     = ["Zsolt Fabok"]
  s.email       = 'me@zsoltfabok.com'
  s.homepage    = ''
  s.license     = 'BSD'

  s.files         = `git ls-files`.split("\n").reject {|path| path =~ /\.gitignore$/ || path =~ /file$/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency('rspec', '~> 3.0')
  s.add_development_dependency('rake', '~> 10.3')
  s.add_development_dependency('leankitkanban', '~> 0.1')
end
