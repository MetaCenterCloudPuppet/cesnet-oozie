# == Class oozie::params
#
# This class is meant to be called from oozie.
# It sets variables according to platform.
#
class oozie::params {
  $alternatives = $::osfamily ? {
    debian => 'cluster',
    redhat => undef,
  }

  $confdir = $::osfamily ? {
    debian => '/etc/oozie/conf',
    redhat => '/etc/oozie',
  }

  $daemon = 'oozie'

  $hadoop_confdir = $::osfamily ? {
    debian => '/etc/hadoop/conf',
    redhat => '/etc/hadoop',
  }

  $oozie_homedir = '/var/lib/oozie'

  case $::osfamily {
    'debian': {
      $packages = {
        'server' => 'oozie',
        'client' => 'oozie-client',
      }
    }
    'redhat': {
      $packages = {
        'server' => 'oozie',
        'client' => 'oozie',
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

}
