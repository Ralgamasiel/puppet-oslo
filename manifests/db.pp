# == Define: oslo::db
#
# Configure oslo_db options
#
# This resource configures Oslo database configs for an OpenStack service.
# It will manage the [database] section in the given config resource.
#
# === Parameters:
#
# [*sqlite_db*]
#   (Optional) The file name to use with SQLite.
#   Defaults to $::os_service_default
#
# [*sqlite_synchronous*]
#   (Optional) If True, SQLite uses synchronous mode (boolean value).
#   Defaults to $::os_service_default
#
# [*backend*]
#   (Optional) The back end to use for the database.
#   Defaults to $::os_service_default
#
# [*connection*]
#   (Optional) The SQLAlchemy connection string to use to connect to the database.
#   Defaults to $::os_service_default
#
# [*slave_connection*]
#   (Optional) The SQLAlchemy connection string to use to connect to the slave database.
#   Defaults to $::os_service_default
#
# [*mysql_sql_mode*]
#   (Optional) The SQL mode to be used for MySQL sessions.
#   Defaults to $::os_service_default
#
# [*idle_timeout*]
#   (Optional) Timeout before idle SQL connections are reaped.
#   Defaults to $::os_service_default
#
# [*min_pool_size*]
#   (Optional) Minimum number of SQL connections to keep open in a pool.
#   Defaults to $::os_service_default
#
# [*max_pool_size*]
#   (Optional) Maximum number of SQL connections to keep open in a pool.
#   Defaults to $::os_service_default
#
# [*max_retries*]
#   (Optional) Maximum number of database connection retries during startup.
#   Set to -1 to specify an infinite retry count.
#   Defaults to $::os_service_default
#
# [*retry_interval*]
#   (Optional) Interval between retries of opening a SQL connection.
#   Defaults to $::os_service_default
#
# [*max_overflow*]
#   (Optional) If set, use this value for max_overflow with SQLALchemy.
#   Defaults to $::os_service_default
#
# [*connection_debug*]
#   (Optional) Verbosity of SQL debugging information: 0=None, 100=Everything.
#   Defaults to $::os_service_default
#
# [*connection_trace*]
#   (Optional) Add Python stack traces to SQL as comment strings (boolean value).
#   Defaults to $::os_service_default
#
# [*pool_timeout*]
#   (Optional) If set, use this value for pool_timeout with SQLAlchemy.
#   Defaults to $::os_service_default
#
# [*use_db_reconnect*]
#   (Optional) Enable the experimental use of database reconnect on connection lost (boolean value)
#   Defaults to $::os_service_default
#
# [*db_retry_interval*]
#   (Optional) Seconds between retries of a database transaction.
#   Defaults to $::os_service_default
#
# [*db_inc_retry_interval*]
#   (Optional) If True, increases the interval between retries of
#   a database operation up to db_max_retry_interval.
#   Defaults to $::os_service_default.
#
# [*db_max_retry_interval*]
#   (Optional) If db_inc_retry_interval is set, the maximum seconds between
#   retries of adatabase operation.
#   Defaults to $::os_service_default
#
# [*db_max_retries*]
#   (Optional) Maximum retries in case of connection error or deadlock error
#   before error is raised. Set to -1 to specify an infinite retry count.
#   Defaults to $::os_service_default
#
# [*use_tpool*]
#   (Optional) Enable the experimental use of thread pooling for all DB API calls (boolean value)
#   Defaults to $::os_service_default
#
define oslo::db(
  $sqlite_db             = $::os_service_default,
  $sqlite_synchronous    = $::os_service_default,
  $backend               = $::os_service_default,
  $connection            = $::os_service_default,
  $slave_connection      = $::os_service_default,
  $mysql_sql_mode        = $::os_service_default,
  $idle_timeout          = $::os_service_default,
  $min_pool_size         = $::os_service_default,
  $max_pool_size         = $::os_service_default,
  $max_retries           = $::os_service_default,
  $retry_interval        = $::os_service_default,
  $max_overflow          = $::os_service_default,
  $connection_debug      = $::os_service_default,
  $connection_trace      = $::os_service_default,
  $pool_timeout          = $::os_service_default,
  $use_db_reconnect      = $::os_service_default,
  $db_retry_interval     = $::os_service_default,
  $db_inc_retry_interval = $::os_service_default,
  $db_max_retry_interval = $::os_service_default,
  $db_max_retries        = $::os_service_default,
  $use_tpool             = $::os_service_default,
){

  if !is_service_default($connection) {

    validate_re($connection,
      '^(sqlite|mysql(\+pymysql)?|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

    case $connection {
      /^mysql(\+pymysql)?:\/\//: {
        require 'mysql::bindings'
        require 'mysql::bindings::python'
        if $connection =~ /^mysql\+pymysql/ {
          $backend_package = $::oslo::params::pymysql_package_name
        } else {
          $backend_package = false
        }
      }
      /^postgresql:\/\//: {
        $backend_package = false
        require 'postgresql::lib::python'
      }
      /^sqlite:\/\//: {
        $backend_package = $::oslo::params::sqlite_package_name
      }
      default: {
        fail('Unsupported backend configured')
      }
    }

    if $backend_package and !defined(Package[$backend_package]) {
      package { 'db_backend_package':
        ensure => present,
        name   => $backend_package,
      }
    }
  }

  create_resources($name, {'database/sqlite_db'             => { value => $sqlite_db }})
  create_resources($name, {'database/sqlite_synchronous'    => { value => $sqlite_synchronous }})
  create_resources($name, {'database/backend'               => { value => $backend }})
  create_resources($name, {'database/connection'            => { value => $connection, secret => true }})
  create_resources($name, {'database/slave_connection'      => { value => $slave_connection, secret => true }})
  create_resources($name, {'database/mysql_sql_mode'        => { value => $mysql_sql_mode }})
  create_resources($name, {'database/idle_timeout'          => { value => $idle_timeout }})
  create_resources($name, {'database/min_pool_size'         => { value => $min_pool_size }})
  create_resources($name, {'database/max_pool_size'         => { value => $max_pool_size }})
  create_resources($name, {'database/max_retries'           => { value => $max_retries }})
  create_resources($name, {'database/retry_interval'        => { value => $retry_interval }})
  create_resources($name, {'database/max_overflow'          => { value => $max_overflow }})
  create_resources($name, {'database/connection_debug'      => { value => $connection_debug }})
  create_resources($name, {'database/connection_trace'      => { value => $connection_trace }})
  create_resources($name, {'database/pool_timeout'          => { value => $pool_timeout }})
  create_resources($name, {'database/use_db_reconnect'      => { value => $use_db_reconnect }})
  create_resources($name, {'database/db_retry_interval'     => { value => $db_retry_interval }})
  create_resources($name, {'database/db_inc_retry_interval' => { value => $db_inc_retry_interval }})
  create_resources($name, {'database/db_max_retry_interval' => { value => $db_max_retry_interval }})
  create_resources($name, {'database/db_max_retries'        => { value => $db_max_retries }})
  create_resources($name, {'database/use_tpool'             => { value => $use_tpool }})

}
