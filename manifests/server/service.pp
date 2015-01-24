# == Class oozie::server::service
#
class oozie::server::service {
  $touchfile = '/var/lib/oozie/.puppet-oozie-schema-created'

  exec { 'oozie-schema':
    command => "/usr/lib/oozie/bin/ooziedb.sh create -run && touch ${touchfile}",
    user    => 'oozie',
    creates => $touchfile,
  }
  ->
  service { $::oozie::daemon:
    ensure    => 'running',
    enable    => true,
    subscribe => [File["${::oozie::confdir}/oozie-site.xml"]],
  }
}
