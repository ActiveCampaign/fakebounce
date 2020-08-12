# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fakebounce/version'

Gem::Specification.new do |s|
  s.name        = 'fakebounce'
  s.version     = FakeBounce::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'

  s.authors     = ['Igor Balos']
  s.email       = ['ibalosh@gmail.com', 'igor@wildbit.com']

  s.summary     = 'Bounce generating tool.'
  s.description = 'Bounce generating tool for testing.'

  s.files       = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  s.test_files  = `git ls-files -- {spec}/*`.split("\n")
  s.homepage    = 'https://github.com/wildbit/fakebounce'
  s.require_paths = ['lib']
  s.required_rubygems_version = '>= 2.6.0'
  s.add_dependency 'mail','~> 2.7', '>= 2.7.1'
  s.add_dependency 'postmark', '~> 1.21', '>= 1.21.1'
  s.add_development_dependency 'pry', '~> 0.13'
  s.add_development_dependency 'rspec', '~> 3.9.0'
end
