# frozen_string_literal: true

require 'spec_helper'
require 'puppet/util/trocla_helper'

describe 'trocla' do
  # This file does not test actual results of the call to trocla. That's been
  # done with the spec file for TroclaHelper already. Here we mostly just want
  # to make sure that the helper function is getting called with a set of
  # parameter values that are being tested in the TroclaHelper spec.
  #
  context 'with default format and no options' do
    it do
      # return value is inconsequential but it lets us abstract away the actual
      # helper code. What we're interested in here is the expected arguments to
      # TroclaHelper::trocla
      allow(Puppet::Util::TroclaHelper).to receive(:trocla).with(:password, true, ['test']).and_return('XXX')
      is_expected.to run.with_params('test')
    end
  end

  context 'with alternative format but no options' do
    it do
      allow(Puppet::Util::TroclaHelper).to receive(:trocla).with(:password, true, ['bar', 'mysql']).and_return('XXX')
      is_expected.to run.with_params('bar', 'mysql')
    end
  end

  context 'with format and options' do
    it do
      allow(Puppet::Util::TroclaHelper).to receive(:trocla).with(:password, true, ['long', 'plain', { 'length' => '5' }]).and_return('XXX')
      is_expected.to run.with_params('long', 'plain', { 'length' => '5' })
    end
  end
end
