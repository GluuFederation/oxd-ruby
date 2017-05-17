# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oxd/version'

Gem::Specification.new do |spec|
  spec.name          = "oxd-ruby"
  spec.version       = Oxd::VERSION
  spec.authors       = ["inderpal6785"]
  spec.email         = ["inderpal6785@gmail.com"]

  spec.summary       = %q{Ruby Client Library for Oxd Server - OpenID Connect Client RP Middleware, which organizes authentication and registration of users.}
  spec.homepage      = "https://github.com/GluuFederation/oxd-ruby"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
end
