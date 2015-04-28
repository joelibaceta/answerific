# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'answerific/version'

Gem::Specification.new do |spec|
  spec.name          = "answerific"
  spec.version       = Answerific::VERSION
  spec.authors       = ["Justin Domingue"]
  spec.email         = ["justin.domingue@hotmail.com"]

  spec.summary       = 'Bot that answers natural language questions.'
  spec.homepage      = 'https://github.com/justindomingue/answerific'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-nc"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"

  spec.add_runtime_dependency "google-search"
end
