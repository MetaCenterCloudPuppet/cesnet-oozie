# == Class oozie::server::config
#
class oozie::server::config {
  contain oozie::common::config

  $jdbc_src = $::oozie::db ? {
    'mysql'      => '/usr/share/java/mysql-connector-java.jar',
    'mariadb'    => '/usr/share/java/mysql-connector-java.jar',
    'postgresql' => '/usr/share/java/postgresql.jar',
    default    => undef,
  }
  $jdbc_dst = $::oozie::db ? {
    'mysql'      => '/usr/lib/oozie/lib/mysql-connector-java.jar',
    'mariadb'    => '/usr/lib/oozie/lib/mysql-connector-java.jar',
    'postgresql' => '/usr/lib/oozie/lib/postgresql.jar',
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
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'
  exec { 'oozie-setup':
    command => "oozie-setup sharelib create -fs ${::oozie::_defaultFS} -locallib ${::oozie::oozie_sharelib} && touch ${touchfile_setup}",
    path    => $path,
    creates => $touchfile_setup,
    require => [File["${::oozie::confdir}/oozie-site.xml"], File["${::oozie::confdir}/oozie-env.sh"]],
  }

  if $::oozie::gui_enable {
    exec {'download-ext-2.2':
      command => 'wget -P /var/lib/oozie http://archive.cloudera.com/gplextras/misc/ext-2.2.zip || wget -P /var/lib/oozie http://scientific.zcu.cz/repos/hadoop/contrib/ext-2.2.zip',
      creates => '/var/lib/oozie/ext-2.2',
      path    => $path,
      unless  => 'test -s /var/lib/oozie/ext-2.2.zip',
    }
    ->
    exec {'extract-ext-2.2':
      command => 'unzip ext-2.2.zip',
      creates => '/var/lib/oozie/ext-2.2',
      cwd     => '/var/lib/oozie',
      path    => $path,
    }
  }

  $adminusers = $::oozie::adminusers
  file { "${::oozie::oozie_homedir}/adminusers.txt":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('oozie/adminusers.txt.erb'),
  }

  if $::oozie::realm and $::oozie::realm != '' {
    file { '/etc/security/keytab/oozie.service.keytab':
      owner => 'oozie',
      group => 'oozie',
      mode  => '0400',
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

    file { "${::oozie::oozie_homedir}/http-auth-signature-secret":
      owner  => 'oozie',
      group  => 'oozie',
      mode   => '0400',
      source => '/etc/security/http-auth-signature-secret',
    }

    if $::oozie::acl and $::oozie::acl == true {
      exec { 'setfacl-ssl-oozie':
        command => "setfacl -m u:oozie:r ${::oozie::hadoop_confdir}/ssl-server.xml ${::oozie::hadoop_confdir}/ssl-client.xml && touch ${::oozie::oozie_homedir}/.puppet-ssl-facl",
        path    => '/sbin:/usr/sbin:/bin:/usr/bin',
        creates => "${::oozie::oozie_homedir}/.puppet-ssl-facl",
        require => [
          File["${::oozie::hadoop_confdir}/ssl-client.xml"],
          File["${::oozie::hadoop_confdir}/ssl-server.xml"],
        ],
        before  => Exec['oozie-setup'],
      }

      # ssl-client.xml and ssl-server.xml
      Class['hadoop::common::config'] -> Exec['setfacl-ssl-oozie']
    }
  }
}
