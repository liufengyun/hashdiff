$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'hashdiff/version'

Gem::Specification.new do |s|
  s.name        = %q{hashdiff}
  s.version     = HashDiff::VERSION
  s.license     = 'MIT'
  s.summary     = %q{ HashDiff is a diff lib to compute the smallest difference between two hashes. }
  s.description = %q{ HashDiff is a diff lib to compute the smallest difference between two hashes. }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- Appraisals {spec}/*`.split("\n")

  s.require_paths = ['lib']
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")

  s.authors = ["Liu Fengyun"]
  s.email   = ["liufengyunchina@gmail.com"]

  s.homepage = "https://github.com/liufengyun/hashdiff"

  s.add_development_dependency("rspec",    "~> 2.0")
  s.add_development_dependency("yard")
  s.add_development_dependency("bluecloth")
end
