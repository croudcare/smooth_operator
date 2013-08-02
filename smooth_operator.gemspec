# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'smooth_operator/version'

Gem::Specification.new do |spec|
  spec.name          = "smooth_operator"
  spec.version       = SmoothOperator::VERSION
  spec.authors       = ["João Gonçalves"]
  spec.email         = ["goncalves.joao@gmail.com"]
  spec.description   = %q{ActiveResource alternative}
  spec.summary       = %q{Simple and fully customizable alternative to ActiveResource, based on httparty gem}
  spec.homepage      = "https://github.com/goncalvesjoao/smooth_operator"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency(%q<httparty>, [">= 0.11.0"])
end
