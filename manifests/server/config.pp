# == Class oozie::server::config
#
class oozie::server::config {
  contain oozie::common::config

  $jdbc_src = $::oozie::db ? {
    mysql      => '/usr/share/java/mysql-connector-java.jar',
    mariadb    => '/usr/share/java/mysql-connector-java.jar',
    postgresql => '/usr/share/java/postgresql-jdbc.jar',
    default    => undef,
  }
  $jdbc_dst = $::oozie::db ? {
    mysql      => '/var/lib/oozie/mysql-connector-java.jar',
    mariadb    => '/var/lib/oozie/mysql-connector-java.jar',
    postgresql => '/var/lib/oozie/postgresql-jdbc.jar',
    default    => undef,
  }

  if $jdbc_src and $jdbc_dst {
    file {$jdbc_dst:
      ensure => 'link',
      links  => 'follow',
      source => $jdbc_src,
    }
  }

  $touchfile_setup = '/var/lib/oozie/.puppet-oozie-setup'
  exec { 'oozie-setup':
    command => "oozie-setup sharelib create -fs ${::oozie::_defaultFS} -locallib /usr/lib/oozie/oozie-sharelib-yarn.tar.gz && touch ${touchfile_setup}",
    path    => '/sbin:/usr/sbin:/bin:/usr/bin',
    creates => $touchfile_setup,
    require => [File["${::oozie::confdir}/oozie-site.xml"], File["${::oozie::confdir}/oozie-env.sh"]],
  }

  if $::oozie::realm {
    file { "/etc/security/keytab/oozie.service.keytab":
      owner  => 'oozie',
      group  => 'oozie',
      mode   => '0400',
    }
  }

  if $::oozie::https {
    file { "${::oozie::oozie_homedir}/http.service.keytab":
      owner  => 'oozie',
      group  => 'oozie',
      mode   => '0400',
      source => '/etc/security/keytab/http.service.keytab',
    }

    file { "${::oozie::oozie_homedir}/.keystore":
      owner  => 'oozie',
      group  => 'oozie',
      mode   => '0400',
      source => $::oozie::https_keystore,
    }
  }
}
