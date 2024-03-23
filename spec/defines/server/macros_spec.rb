require 'spec_helper'

describe 'clickhouse::server::macros' do
  let(:title) { 'macros.xml' }
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
        macros_defaults = "\
<clickhouse>
  <macros></macros>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/config.d/macros.xml').with_content(macros_defaults)
      end

      it 'with macros set' do
        params['macros'] = {
          'replica' => 'host.local',
          'shard'   => 1,
        }
        macros_set = "\
<clickhouse>
  <macros>
    <replica>host.local</replica>
    <shard>1</shard>
  </macros>
</clickhouse>
"

        is_expected.to contain_file('/etc/clickhouse-server/config.d/macros.xml').with_content(macros_set)
      end
    end
  end
end
