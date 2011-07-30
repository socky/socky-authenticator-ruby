# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "socky/authenticator/version"

Gem::Specification.new do |s|
  s.name        = "socky-authenticator"
  s.version     = Socky::Authenticator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bernard Potocki"]
  s.email       = ["bernard.potocki@imanel.org"]
  s.homepage    = "http://socky.org"
  s.summary     = %q{Socky - Authentication Module}
  s.description = %q{Socky is a WebSocket-based framework for realtime web applications.}
  
  s.add_dependency 'json'
  s.add_dependency 'ruby-hmac'
  s.add_development_dependency 'rspec', '~> 2.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
