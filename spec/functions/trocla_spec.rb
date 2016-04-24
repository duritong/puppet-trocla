require 'spec_helper'

describe 'trocla' do
  before(:each) do
    scope.stubs(:lookupvar).with("trocla_configfile").returns('spec/fixtures/troclarc.yaml')
  end

  it { should run.with_params('key', 'plain').and_return('foo') }
end
