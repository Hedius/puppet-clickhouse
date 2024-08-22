require 'spec_helper'

describe 'clickhouse::server::profiles' do
  let(:title) { 'profiles.yaml' }
  let(:params) do
    {
      config_dir: '/etc/clickhouse-server/users.d',
      profiles_file_owner: 'clickhouse',
      profiles_file_group: 'clickhouse',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it 'with defaults' do
        profiles_defaults = <<-EOS
---
profiles: {}
EOS
        is_expected.to contain_file('/etc/clickhouse-server/users.d/profiles.yaml').with_content(profiles_defaults)
      end

      it 'with profiles set' do
        params['profiles'] = {
          'web' => {
            'max_threads'      => 1,
            'max_rows_to_read' => 100,
          },
          'readonly' => {
            'readonly' => 1,
          },
        }
        profiles_set = <<-EOS
---
profiles:
  web:
    max_threads: 1
    max_rows_to_read: 100
  readonly:
    readonly: 1
EOS

        is_expected.to contain_file('/etc/clickhouse-server/users.d/profiles.yaml').with_content(profiles_set)
      end
    end
  end
end
