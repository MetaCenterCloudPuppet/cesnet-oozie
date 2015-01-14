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
    exec { 'oozie-install-alternatives':
      command     => "${::oozie::altcmd} --install /etc/oozie/conf oozie-conf /etc/oozie/conf.${confname} 50",
      path        => $path,
      refreshonly => true,
      subscribe   => Exec['oozie-copy-config'],
    }
    ->
    exec { 'oozie-set-alternatives':
      command     => "${::oozie::altcmd} --set oozie-conf /etc/oozie/conf.${confname}",
      path        => $path,
      refreshonly => true,
      subscribe   => Exec['oozie-copy-config'],
    }
  }
}
