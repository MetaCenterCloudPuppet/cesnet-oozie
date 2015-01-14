# == Class oozie::server::install
#
class oozie::server::install {
  include stdlib
  contain oozie::common::postinstall

  ensure_packages($oozie::packages['server'])

  if $::oozie::https {
    $conf = '/etc/oozie/tomcat-conf.https'
  } else {
    $conf = '/etc/oozie/tomcat-conf.https'
  }
  exec { 'oozie-aternatives':
    command => "$::oozie:altcmd --set oozie-tomcat-conf ${conf}"
    path    => '/sbin:/usr/sbin:/bin:/usr/bin',
  }

  Package[$oozie::packages['server']] ~> Exec['oozi-alternatives']
  Package[$oozie::packages['server']] -> Class['oozie::common::postinstall']
}
