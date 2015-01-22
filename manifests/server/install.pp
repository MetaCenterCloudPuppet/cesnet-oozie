# == Class oozie::server::install
#
class oozie::server::install {
  include stdlib
  contain oozie::common::postinstall

  ensure_packages($oozie::packages['server'])

  if $::oozie::https {
    $conf = '/etc/oozie/tomcat-conf.https'
  } else {
    $conf = '/etc/oozie/tomcat-conf.http'
  }
  alternatives{'oozie-tomcat-conf':
    path => $conf,
  }

  Package[$oozie::packages['server']] -> Alternatives['oozie-tomcat-conf']
  Package[$oozie::packages['server']] -> Class['oozie::common::postinstall']
}
