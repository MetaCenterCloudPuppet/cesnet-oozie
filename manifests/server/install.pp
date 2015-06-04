# == Class oozie::server::install
#
class oozie::server::install {
  include stdlib
  contain oozie::common::postinstall

  ensure_packages($oozie::packages['server'])
  ensure_packages($oozie::packages['unzip'])

  if $::oozie::alternatives_ssl and $::oozie::alternatives_ssl != '' {
    if $::oozie::https {
      $conf = '/etc/oozie/tomcat-conf.https'
    } else {
      $conf = '/etc/oozie/tomcat-conf.http'
    }
    alternatives{$::oozie::alternatives_ssl:
      path => $conf,
    }

    Package[$oozie::packages['server']] -> Alternatives[$::oozie::alternatives_ssl]
  }

  Package[$oozie::packages['server']] -> Class['oozie::common::postinstall']
}
