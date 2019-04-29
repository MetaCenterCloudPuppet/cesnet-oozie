# == Class oozie::server::install
#
class oozie::server::install {
  include ::stdlib
  contain oozie::common::postinstall

  ensure_packages($oozie::packages['server'])
  ensure_packages($oozie::packages['unzip'])

  if $::oozie::_alternatives_ssl and $::oozie::_alternatives_ssl != '' {
    if $::oozie::https {
      $conf = '/etc/oozie/tomcat-conf.https'
    } else {
      $conf = '/etc/oozie/tomcat-conf.http'
    }
    alternatives{$::oozie::_alternatives_ssl:
      path => $conf,
    }

    Package[$oozie::packages['server']] -> Alternatives[$::oozie::_alternatives_ssl]
  }

  Package[$oozie::packages['server']] -> Class['oozie::common::postinstall']
}
