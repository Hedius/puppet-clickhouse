require 'spec_helper'

describe 'clickhouse::server::macros' do
  let(:title) { 'macros.yaml' }
  let(:params) do
    {
      config_dir: '/etc/clickhouse-server/config.d',
      macros_file_owner: 'clickhouse',
      macros_file_group: 'clickhouse',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it 'with defaults' do
        macros_defaults = <<-EOS
---
macros: {}
EOS
        is_expected.to contain_file('/etc/clickhouse-server/config.d/macros.yaml').with_content(macros_defaults)
      end

      it 'with macros set' do
        params['macros'] = {
          'replica' => 'host.local',
          'shard'   => 1,
        }
        macros_set = <<-EOS
---
macros:
  replica: host.local
  shard: 1
EOS
        is_expected.to contain_file('/etc/clickhouse-server/config.d/macros.yaml').with_content(macros_set)
      end
    end
  end
end
