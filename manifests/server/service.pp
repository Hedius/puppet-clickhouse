# @summary
#   Private class for managing the Clickhouse service.
#
# @api private
#
class clickhouse::server::service {
  if $clickhouse::server::manage_service {
    service { $clickhouse::server::service_name:
      ensure => $clickhouse::server::service_ensure,
      enable => $clickhouse::server::service_enabled,
    }

    if $clickhouse::server::manage_package {
      Service[$clickhouse::server::service_name] {
        require => Package[$clickhouse::server::package_name],
      }
    }

    if $clickhouse::server::manage_config {
      File["${clickhouse::server::main_dir}/${clickhouse::server::config_file}"] -> Service[$clickhouse::server::service_name]
      Service<| title == $clickhouse::server::service_name |> {
        subscribe => File["${clickhouse::server::main_dir}/${clickhouse::server::config_file}"],
      }
    }

    if $clickhouse::server::manage_systemd {
      $service_overrides  = {
        'User'      => $clickhouse::server::clickhouse_user,
        'Group'     => $clickhouse::server::clickhouse_group,
        'ExecStart' => "/usr/bin/clickhouse-server --config=${clickhouse::server::config_file} --pid-file=%t/%p/%p.pid",
      }
      systemd::dropin_file { 'puppet-clickhouse-server.conf':
        unit    => $clickhouse::server::service_name,
        content => epp("${module_name}/server_dropin.epp", {
            'sections' => $service_overrides,
        }),
      }
      # Probably not needed anymore?
      file { '/etc/default/clickhouse-server':
        owner   => $clickhouse::server::clickhouse_user,
        group   => $clickhouse::server::clickhouse_group,
        mode    => '0664',
        content => epp("${module_name}/server_env.epp", {
            'config' => "${clickhouse::server::main_dir}/${clickhouse::server::config_file}",
        }),
      }
    }
  }
}
