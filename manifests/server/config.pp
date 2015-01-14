# == Class oozie::server::config
#
class oozie::server::config {
  $jdbc = $::oozie::db ? {
    mysql      => '/usr/lib/hive/lib/mysql-connector-java.jar',
    mariadb    => '/usr/lib/hive/lib/mysql-connector-java.jar',
    postgresql => '/usr/lib/hive/lib/postgresql-jdbc.jar',
  }

  if $jdbc {
    file { '/var/lib/oozie/':
      ensure => 'link',
      links  => 'follow',
      source => $jdbc,
    }
  }

  file { "${::oozzie::confdir}/oozie-site.xml":
    owner   => 'root',
    group   => 'root',
    mode   => '0640',
    content => template('oozie/oozie-site.xml.erb'),
  }
}
