source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 7.1.0']
end

gem 'librarian-puppet'
gem 'puppetlabs_spec_helper'
gem 'rake'

gem 'puppet', puppetversion
gem 'puppet-lint'
