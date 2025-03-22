# lint:ignore:2sp_soft_tabs
type Clickhouse::Clickhouse_roles = Hash[String, Struct[{grants                    => Array[String],
                                                         Optional[users_dir]       => Stdlib::Unixpath,
                                                         Optional[user_file_owner] => String,
                                                         Optional[user_file_group] => String,
                                                         Optional[ensure]          => String}],1]
# lint:endignore
