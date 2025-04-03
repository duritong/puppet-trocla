source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 7.1.0']
end

gem 'rake'
gem 'puppet', puppetversion
gem 'trocla'

group :tests do
  gem 'metadata-json-lint'
  gem 'puppetlabs_spec_helper'
  gem 'puppet-lint'
  gem 'puppet_metadata'
  gem 'puppet-syntax'
  # This draws in rubocop and other useful gems for puppet tests
  gem 'voxpupuli-test'
end
