source 'https://rubygems.org'

if ENV.key?('PUPPET_VERSION')
  puppetversion = "~> #{ENV['PUPPET_VERSION']}"
else
  puppetversion = ['>= 3.8.6']
end

if RUBY_VERSION == '1.8.7'
  puppetversion = ['~> 3.8.6']
  gem 'i18n', '~> 0.6.11'
  gem 'activesupport', '~> 3.2'
  gem 'highline', '~> 1.6.21'
  gem 'librarian-puppet', '~> 1.0.0'
  gem 'rspec', '~> 3.1.0'
  gem 'rake', '< 11'
else
  gem 'librarian-puppet'
  gem 'rake'
end

gem 'puppet', puppetversion
gem 'puppet-lint'
gem 'puppetlabs_spec_helper'

gem 'trocla'
