require 'spec_helper'

describe 'clickhouse::server::dictionary' do
  let(:title) { 'products.xml' }
  let(:params) do
    {
      dict_dir: '/etc/clickhouse-server/dict',
      dict_file_owner: 'clickhouse',
      dict_file_group: 'clickhouse',
      source: 'puppet:///modules/clickhouse/products.xml',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end

    context 'with source set' do
      let(:facts) { os_facts }

      it {
        is_expected.to contain_file('/etc/clickhouse-server/dict/products.xml').with(
          ensure: 'present',
          mode: '0440',
          owner: 'clickhouse',
          group: 'clickhouse',
          source: 'puppet:///modules/clickhouse/products.xml',
        )
      }
    end

    context 'with content set' do
      let(:title) { 'example.yaml' }
      let(:facts) { os_facts }

      example_content = <<-EOS
---
dictionaries:
  dictionary:
    - name: example
      source:
        file:
          path: example.csv
          format: CSVWithNames
      lifetime: 300
      layout:
        hashed: {}
      structure:
        id:
          name: id
        attribute:
          - name: keyword
            type: String
            null_value: "?"
          - name: protocol
            type: String
            null_value: "?"
          - name: reference
            type: String
            null_value: "?"
EOS


      it {
        params['content'] = example_content
        is_expected.to contain_file('/etc/clickhouse-server/dict/example.yaml').with(
          ensure: 'present',
          mode: '0440',
          owner: 'clickhouse',
          group: 'clickhouse',
        ).with_content(example_content)
      }
    end
  end
end
