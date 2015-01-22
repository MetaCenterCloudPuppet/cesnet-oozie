# == Class oozie::common::postinstall
#
# Preparation steps after installation. It switches oozie-conf alternative, if enabled.
#
class oozie::common::postinstall {
  $confname = $::oozie::alternatives
  $path = '/sbin:/usr/sbin:/bin:/usr/bin'

  if $confname {
    exec { 'oozie-copy-config':
      command => "cp -a ${oozie::confdir}/ /etc/oozie/conf.${confname}",
      path    => $path,
      creates => "/etc/oozie/conf.${confname}",
    }
    ->
    alternative_entry{"/etc/oozie/conf.${confname}":
      altlink => '/etc/oozie/conf',
      altname => 'oozie-conf',
      priority => 50,
    }
    ->
    alternatives{"oozie-conf":
      path => "/etc/oozie/conf.${confname}",
    }
  }
}
