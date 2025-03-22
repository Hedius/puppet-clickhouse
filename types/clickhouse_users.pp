# lint:ignore:2sp_soft_tabs
type Clickhouse::Clickhouse_users = Hash[String, Struct[{Optional[password]             => String,
                                                         Optional[quota]                => String,
                                                         Optional[profile]              => String,
                                                         Optional[allow_databases]      => Array[String],
                                                         Optional[default_database]     => String,
                                                         Optional[grants]               => Array[String],
                                                         Optional[networks]             => Clickhouse::Clickhouse_networks,
                                                         Optional[users_dir]            => Stdlib::Unixpath,
                                                         Optional[user_file_owner]      => String,
                                                         Optional[user_file_group]      => String,
                                                         Optional[enable_sql_user_mode] => Boolean,
                                                         Optional[ensure]               => String}],1]
# lint:endignore
