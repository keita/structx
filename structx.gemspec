# -*- ruby -*-
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'structx/version'

Gem::Specification.new do |spec|
  spec.name          = "structx"
  spec.version       = StructX::VERSION
  spec.authors       = ["Keita Yamaguchi"]
  spec.email         = ["keita.yamaguchi@gmail.com"]
  spec.description   = "sturctx is a Ruby library that extends standard Struct"
  spec.summary       = "sturctx is a Ruby library that extends standard Struct"
  spec.homepage      = "https://github.com/keita/structx"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "forwardablex"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "bacon"
  spec.add_development_dependency "yard"
  spec.add_development_dependency "ruby-version"
end
