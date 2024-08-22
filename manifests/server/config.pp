# @summary
#   Private class for Clickhouse server configuration.
#
# @api private
#
class clickhouse::server::config {
  $default_options = {
    'listen_host'            => '::',
    'dictionaries_config'    => "${clickhouse::server::dict_dir}/*",
    'max_table_size_to_drop' => 0,
    'path'                   => $clickhouse::server::clickhouse_datadir,
    'tmp_path'               => $clickhouse::server::clickhouse_tmpdir,
    'user_directories' => {
      'users_xml' => {
        'path' => 'users.xml',
      },
      'local_directory' => {
        'path' => "${clickhouse::server::clickhouse_datadir}access/",
      },
    },
  }

  $options = $default_options.deep_merge($clickhouse::server::override_options)

  if $clickhouse::server::manage_config {
    $recurse = true
    $purge = true
  } else {
    $recurse = false
    $purge = false
  }

  file { [$clickhouse::server::clickhouse_datadir, $clickhouse::server::clickhouse_tmpdir, $clickhouse::server::main_dir]:
    ensure => 'directory',
    mode   => '0750',
    owner  => $clickhouse::server::clickhouse_user,
    group  => $clickhouse::server::clickhouse_group,
  }

  file { [$clickhouse::server::config_dir, $clickhouse::server::users_dir, $clickhouse::server::dict_dir]:
    ensure  => 'directory',
    mode    => '0750',
    owner   => $clickhouse::server::clickhouse_user,
    group   => $clickhouse::server::clickhouse_group,
    recurse => $recurse,
    purge   => $purge,
    require => File[$clickhouse::server::main_dir],
  }

  if $clickhouse::server::manage_config {
    # wipe old config files.
    file { ["${clickhouse::server::main_dir}/config.xml", "${clickhouse::server::main_dir}/conf.d"]:
      ensure  => absent,
      purge   => true,
      recurse => true,
      force   => true,
    }

    file { "${clickhouse::server::main_dir}/${clickhouse::server::config_file}":
      content => stdlib::to_yaml($options),
      mode    => '0440',
      owner   => $clickhouse::server::clickhouse_user,
      group   => $clickhouse::server::clickhouse_group,
    }

    if !($clickhouse::server::keep_default_users) {
      file { '/etc/clickhouse-server/users.xml':
        content => "<clickhouse>\r\n\t<users>\r\n\t</users>\r\n</clickhouse>\r\n",
        mode    => '0440',
        owner   => $clickhouse::server::clickhouse_user,
        group   => $clickhouse::server::clickhouse_group,
      }
    }

    if $clickhouse::server::replication {
      file { "${clickhouse::server::config_dir}/${clickhouse::server::zookeeper_config_file}":
        owner   => $clickhouse::server::clickhouse_user,
        group   => $clickhouse::server::clickhouse_group,
        mode    => '0440',
        content => epp("${module_name}/zookeeper.xml.epp", {
            'zookeeper_servers' => $clickhouse::server::replication['zookeeper_servers'],
            'secure'            => $clickhouse::server::replication['secure'],
            'distributed_ddl'   => $clickhouse::server::replication['distributed_ddl'],
        }),
        require => File[$clickhouse::server::config_dir],
      }
    }

    if $clickhouse::server::crash_reports {
      file { "${clickhouse::server::config_dir}/crash_reports.yaml":
        content => stdlib::to_yaml({ 'send_crash_reports' => $clickhouse::server::crash_reports }),
        mode    => '0440',
        owner   => $clickhouse::server::clickhouse_user,
        group   => $clickhouse::server::clickhouse_group,
      }
    }
  }
}
