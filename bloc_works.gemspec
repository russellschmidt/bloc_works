# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bloc_works/version'

Gem::Specification.new do |spec|
  spec.name          = "bloc_works"
  spec.version       = BlocWorks::VERSION
  spec.authors       = ["Russell Schmidt"]
  spec.email         = ["russell.schmidt@me.com"]

  spec.summary       = %q{Learning Web Framework}
  spec.description   = %q{Miniature web framework based on Rails for learning}
  spec.homepage      = "https://github.com/russellschmidt/bloc_works"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rack', '~> 1.6'
  spec.add_development_dependency 'erubis', '~>   2.7'

  spec.add_runtime_dependency 'bloc_record'
end
