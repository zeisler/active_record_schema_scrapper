# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_record_schema_scrapper/version'

Gem::Specification.new do |spec|
  spec.name          = "active_record_schema_scrapper"
  spec.version       = ActiveRecordSchemaScrapper::VERSION
  spec.authors       = ["Dustin Zeisler"]
  spec.email         = ["dustin@zeisler.net"]

  spec.summary       = %q{A wrapper around an active_record model.}
  spec.description   = %q{A supporting library for active_mocker and wrapper around an active_record model.}
  spec.homepage      = "https://github.com/zeisler/active_record_schema_scrapper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord", ">= 4.2", "<= 6.9"
  spec.add_runtime_dependency "virtus", "~> 1.0"
  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "appraisal", "~> 2.0"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.5"
  spec.add_development_dependency "sqlite3", "~> 1.3.6"
end
