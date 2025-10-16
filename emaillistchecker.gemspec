# frozen_string_literal: true

require_relative 'lib/emaillistchecker/version'

Gem::Specification.new do |spec|
  spec.name = 'emaillistchecker'
  spec.version = EmailListChecker::VERSION
  spec.authors = ['EmailListChecker']
  spec.email = ['developers@emaillistchecker.io']

  spec.summary = 'Official Ruby SDK for EmailListChecker email verification API'
  spec.description = 'Ruby client library for the EmailListChecker API. Verify single and bulk email addresses, find emails by name/domain/company, and manage your account.'
  spec.homepage = 'https://emaillistchecker.io'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Emaillistchecker-io/emaillistchecker-ruby'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/Emaillistchecker-io/emaillistchecker-ruby/issues'
  spec.metadata['documentation_uri'] = 'https://platform.emaillistchecker.io/api'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir['lib/**/*.rb'] + Dir['examples/**/*.rb'] + ['README.md', 'LICENSE']
  spec.require_paths = ['lib']

  # Runtime dependencies
  # Using standard library only - no external dependencies

  # Development dependencies
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
