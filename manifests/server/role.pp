# @summary
#   Create and manage Clickhouse roles.
#
# @see https://clickhouse.com/docs/operations/settings/settings-users#roles
#
# @example Create Clickhouse role.
#   clickhouse::server::role { 'test_role':
#     grants => [
#       'GRANT SHOW ON *.*',
#       'GRANT CREATE ON *.* WITH GRANT OPTION',
#     ],
#   }
#
# @param name
#   Name of the ClickHouse role. Will be also used as a file name for the configuration file in $users_dir folder.
# @param grants
#   Array of grants that should be applied. Not verified!
# @param users_dir
#   Path to directory, where user configuration will be stored. Defaults to '/etc/clickhouse-server/users.d/'
# @param user_file_owner
#   Owner of the user file. Defaults to 'clickhouse'.
# @param user_file_group
#   Group of the user file. Defaults to 'clickhouse'.
# @param ensure
#   Specifies whether to create user. Valid values are 'present', 'absent'. Defaults to 'present'.
#
define clickhouse::server::role (
  Array[String] $grants             = undef,
  Stdlib::Unixpath $users_dir       = $clickhouse::server::users_dir,
  String $user_file_owner           = $clickhouse::server::clickhouse_user,
  String $user_file_group           = $clickhouse::server::clickhouse_group,
  Enum['present', 'absent'] $ensure = 'present',
) {
  file { "${users_dir}/role_${title}.xml":
    ensure  => $ensure,
    owner   => $user_file_owner,
    group   => $user_file_group,
    mode    => '0664',
    content => epp("${module_name}/role.xml.epp", {
        'role'   => $title,
        'grants' => $grants,
    }),
  }
}
