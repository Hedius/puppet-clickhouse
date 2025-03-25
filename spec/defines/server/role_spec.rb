require 'spec_helper'

describe 'clickhouse::server::role' do
  let(:title) { 'test' }
  let(:params) do
    {
      grants: ['GRANT SHOW ON *.*', 'GRANT SELECT ON test.*'],
      users_dir: '/etc/clickhouse-server/users.d',
      user_file_owner: 'clickhouse',
      user_file_group: 'clickhouse',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }

      it 'with defaults' do
        test_role = "\
<clickhouse>
  <roles>
    <test>
      <grants>
        <query>GRANT SHOW ON *.*</query>
        <query>GRANT SELECT ON test.*</query>
      </grants>
    </test>
  </roles>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/role_test.xml').with_content(test_role)
      end
    end
  end
end
