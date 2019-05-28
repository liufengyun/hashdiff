# frozen_string_literal: true

$LOAD_PATH << File.expand_path('lib', __dir__)
require 'hashdiff/version'

Gem::Specification.new do |s|
  s.name        = 'hashdiff'
  s.version     = Hashdiff::VERSION
  s.license     = 'MIT'
  s.summary     = ' Hashdiff is a diff lib to compute the smallest difference between two hashes. '
  s.description = ' Hashdiff is a diff lib to compute the smallest difference between two hashes. '

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- Appraisals {spec}/*`.split("\n")

  s.require_paths = ['lib']
  s.required_ruby_version = Gem::Requirement.new('>= 2.0.0')
  s.post_install_message = 'The HashDiff constant used by this gem conflicts with another gem of a similar name.  As of version 1.0 the HashDiff constant will be completely removed and replaced by Hashdiff.  For more information see https://github.com/liufengyun/hashdiff/issues/45.'

  s.authors = ['Liu Fengyun']
  s.email   = ['liufengyunchina@gmail.com']

  s.homepage = 'https://github.com/liufengyun/hashdiff'

  s.add_development_dependency('bluecloth')
  s.add_development_dependency('rspec', '~> 2.0')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('rubocop-rspec')
  s.add_development_dependency('yard')

  if s.respond_to?(:metadata)
    s.metadata = {
      'bug_tracker_uri' => 'https://github.com/liufengyun/hashdiff/issues',
      'changelog_uri' => 'https://github.com/liufengyun/hashdiff/blob/master/changelog.md',
      'documentation_uri' => 'https://www.rubydoc.info/gems/hashdiff',
      'homepage_uri' => 'https://github.com/liufengyun/hashdiff',
      'source_code_uri' => 'https://github.com/liufengyun/hashdiff'
    }
  end
end
