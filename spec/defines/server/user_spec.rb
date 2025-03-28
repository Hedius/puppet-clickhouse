require 'spec_helper'

describe 'clickhouse::server::user' do
  let(:title) { 'alice' }
  let(:params) do
    {
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
        alice_defaults = "\
<clickhouse>
  <users>
    <alice>
      <quota>default</quota>
      <profile>default</profile>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_defaults)
      end

      alice_password = "\
<clickhouse>
  <users>
    <alice>
      <password_sha256_hex>21597f1f8d7874eeb0d08e485c146c3067dc502512c6edaa38e0eabb3c4280a6</password_sha256_hex>
      <quota>default</quota>
      <profile>default</profile>
    </alice>
  </users>
</clickhouse>
"

      it 'with cleartext password' do
        params['password'] = 'helloAlice'
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_password)
      end

      it 'with sha256 password' do
        params['password'] = '21597f1f8d7874eeb0d08e485c146c3067dc502512c6edaa38e0eabb3c4280a6'
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_password)
      end

      it 'with allow_databases' do
        params['allow_databases'] = ['db1', 'db2']
        alice_databases = "\
<clickhouse>
  <users>
    <alice>
      <quota>default</quota>
      <profile>default</profile>
      <allow_databases>
        <database>db1</database>
        <database>db2</database>
      </allow_databases>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_databases)
      end

      it 'with default_database' do
        params['default_database'] = 'db1'
        alice_default_db = "\
<clickhouse>
  <users>
    <alice>
      <quota>default</quota>
      <profile>default</profile>
      <default_database>db1</default_database>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_default_db)
      end

      it 'with grants' do
        params['grants'] = ['GRANT test_role', 'GRANT SELECT ON db1.*']
        alice_grants = "\
<clickhouse>
  <users>
    <alice>
      <quota>default</quota>
      <profile>default</profile>
      <grants>
        <query>GRANT test_role</query>
        <query>GRANT SELECT ON db1.*</query>
      </grants>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_grants)
      end

      it 'with profile override' do
        params['profile'] = 'test'
        alice_profile = "\
<clickhouse>
  <users>
    <alice>
      <quota>default</quota>
      <profile>test</profile>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_profile)
      end

      it 'with quota override' do
        params['quota'] = 'test'
        alice_profile = "\
<clickhouse>
  <users>
    <alice>
      <quota>test</quota>
      <profile>default</profile>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_profile)
      end

      it 'with networks' do
        params['networks'] = {
          'ip'          => ['::/0', '::'],
          'host'        => ['localhost', 'host1.local'],
          'host_regexp' => ['^local.*', '^remote.*'],
        }
        alice_networks = "\
<clickhouse>
  <users>
    <alice>
      <quota>default</quota>
      <profile>default</profile>
      <networks>
        <ip>::/0</ip>
        <ip>::</ip>
        <host>localhost</host>
        <host>host1.local</host>
        <host_regexp>^local.*</host_regexp>
        <host_regexp>^remote.*</host_regexp>
      </networks>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_networks)
      end

      it 'with sql user mode' do
        params['enable_sql_user_mode'] = true
        alice_profile = "\
<clickhouse>
  <users>
    <alice>
      <quota>default</quota>
      <profile>default</profile>
      <access_management>1</access_management>
      <named_collection_control>1</named_collection_control>
      <show_named_collections>1</show_named_collections>
      <show_named_collections_secrets>1</show_named_collections_secrets>
    </alice>
  </users>
</clickhouse>
"
        is_expected.to contain_file('/etc/clickhouse-server/users.d/alice.xml').with_content(alice_profile)
      end
    end
  end
end
