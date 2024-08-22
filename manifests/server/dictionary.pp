# @summary 
#   Create and manage a Clickhouse dictionary.
#
# @see https://clickhouse.com/docs/en/query_language/dicts/external_dicts/
#
# @example Create a basic Clickhouse dictionary based on a source:
#   clickhouse::server::dictionary { 'countries.xml': 
#     source => 'puppet:///modules/clickhouse/dictionaries',
#   }
#
# @example Create a basic Clickhouse dictionary based on a defined content:
#   clickhouse::server::dictionary { 'countries.xml': 
#     content => '...',
#   }
#
# @param name
#   Name of the dictionary file in the $source and $dict_dir folders.
# @param dict_dir
#   Path to folder with clickhouse dictionaries. Defaults to '/etc/clickhouse-server/dict'.
# @param dict_file_owner
#   Owner of the dictionary file. Defaults to 'clickhouse'.
# @param dict_file_group
#   Group of the dictionary file. Defaults to 'clickhouse'.
# @param ensure
#   Specifies whether to create dictionary. Valid values are 'present', 'absent'. Defaults to 'present'.
# @param source
#   Path to a 'files' folder in puppet, where dictionary file are located. Defaults to 'puppet:///modules/${module_name}'.
#   Not validated.
# @param content
#   Sets the content of the dictionary. Not validated.
#
define clickhouse::server::dictionary (
  Stdlib::Unixpath $dict_dir        = $clickhouse::server::dict_dir,
  String $dict_file_owner           = $clickhouse::server::clickhouse_user,
  String $dict_file_group           = $clickhouse::server::clickhouse_group,
  Enum['present', 'absent'] $ensure = 'present',
  String $source                    = "${clickhouse::server::dict_source_folder}/${title}",
  Optional[String] $content         = undef,
) {
  if $content {
    $_content = $content
    $_source = undef
  } else {
    $_content = undef
    $_source = $source
  }
  file { "${dict_dir}/${title}":
    ensure  => $ensure,
    owner   => $dict_file_owner,
    group   => $dict_file_group,
    mode    => '0440',
    source  => $_source,
    content => $_content,
  }
}
