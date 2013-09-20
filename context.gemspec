# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'context/version'

Gem::Specification.new do |spec|
  spec.name          = "desktop-context"
  spec.version       = Context::VERSION
  spec.authors       = ["Ben Eills"]
  spec.email         = ["ben@beneills.com"]
  spec.description   = "Create desktop /contexts/ with custom entry/exit actions"
  spec.summary       = "Create desktop /contexts/ with custom entry/exit actions"
  spec.homepage      = "http://www.beneills.com/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "trollop"
  spec.add_dependency "fileutils"
end
