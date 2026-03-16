source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? ENV['PUPPET_VERSION'].to_s : ['>= 7.1.0']

gem 'rake'
gem 'puppet', puppetversion
gem 'trocla'

group :tests do
  # This draws in rubocop and other useful gems for puppet tests
  gem 'voxpupuli-test', '~> 14.0.0'
  # Brings metadata2gha for CI
  gem 'puppet_metadata', '< 7.0.0'
end

group :docs do
  gem 'puppet-strings', '< 6.0.0'
end
