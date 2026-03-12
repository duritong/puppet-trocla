# frozen_string_literal: true

require 'spec_helper'

describe 'trocla::yaml', type: 'class' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'with default params' do
        it {
          is_expected.to contain_class('trocla::config').with(
            'store' => 'moneta',
            'store_options' => {
              'adapter' => 'YAML',
              'adapter_options' => {
                'file' => '/var/lib/trocla/trocla_data.yaml',
              },
            },
          )
        }

        it {
          # NOTE: default fact sets from rspec-puppet-facts contain fact
          # networking.domain == 'example.com', thus the value seen in the
          # string below
          is_expected.to contain_file('/etc/puppet/troclarc.yaml').with_content("---
profiles:
  sysdomain_nc:
    name_constraints:
      - example.com
store: :moneta
store_options:
  adapter: :YAML
  adapter_options:
    :file: /var/lib/trocla/trocla_data.yaml
")
        }

        it {
          is_expected.to contain_file('/var/lib/trocla').with(
            ensure: 'directory',
            owner: 'puppet',
            group: 0,
            mode: '0600',
          )
        }

        it {
          is_expected.to contain_file('/var/lib/trocla/trocla_data.yaml').with(
            ensure: 'file',
            owner: 'puppet',
            group: 0,
            mode: '0600',
          )
        }

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
