require 'rspec-puppet-facts'
require 'voxpupuli/test/spec_helper'

RSpec.configure do |c|
  c.confdir = '/etc/puppet'
end
