# == Class oozie::params
#
# This class is meant to be called from oozie.
# It sets variables according to platform.
#
class oozie::params {
  $altcmd = $::osfamily ? {
    debian => 'update-alternatives',
    redhat => 'alternatives',
  }

  $alternatives = $::osfamily ? {
    debian => 'cluster',
    redhat => undef,
  }

  $confdir = $::osfamily ? {
    debian => '/etc/oozie/conf',
    redhat => '/etc/oozie',
  }

  $hadoop_confdir = $::osfamily ? {
    debian => '/etc/hadoop/conf',
    redhat => '/etc/hadoop',
  }

  $packages = $::osfamily ? {
    debian => {
        'server' => 'oozie',
        'client' => 'oozie-client',
    }
    redhat => {
        'server' => 'oozie',
        'client' => 'oozie',
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }

  $daemon = 'oozie'  
}
