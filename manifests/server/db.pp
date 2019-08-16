# == Class oozie::server::db
#
# Initialize Oozie server database.
#
# Requires all install, config, and service classes.
#
class oozie::server::db {
  include ::stdlib

  $db = $::oozie::db ? {
    'derby'         => 'derby',
    /mysql|mariadb/ => 'mysql',
    'postgresql'    => 'postgresql',
    'oracle'        => 'oracle',
    default         => 'derby',
  }

  if $::oozie::db and $::oozie::database_setup_enable {
    if $db == 'mysql' {
      mysql::db { $::oozie::db_name:
        user     => $::oozie::db_user,
        password => $::oozie::db_password,
        host     => $::oozie::db_host,
        grant    => ['CREATE', 'INDEX', 'SELECT', 'INSERT', 'UPDATE', 'DELETE'],
      }

      Class['mysql::bindings'] -> Class['oozie::server::config']
      Mysql::Db[$::oozie::db_name] -> Class['oozie::server::service']
    }

    if ($db == 'postgresql') {
      postgresql::server::db { $::oozie::db_name:
        user     => $::oozie::db_user,
        password => postgresql_password($::oozie::db_user, $::oozie::db_password),
      }

      Class['postgresql::lib::java'] -> Class['oozie::server::config']
      Postgresql::Server::Db[$::oozie::db_name] -> Class['oozie::server::service']
    }
  }
}
