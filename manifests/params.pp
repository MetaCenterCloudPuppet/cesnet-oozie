# == Class oozie::params
#
# This class is meant to be called from oozie.
# It sets variables according to platform.
#
class oozie::params {
  $alternatives = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => undef,
    # https://github.com/puppet-community/puppet-alternatives/issues/18
    /RedHat/        => '',
    /Debian/        => 'cluster',
  }

  $alternatives_ssl = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => false,
    /Debian|RedHat/ => true,
  }

  $confdir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/oozie',
    /Debian|RedHat/ => '/etc/oozie/conf',
  }

  $daemon = 'oozie'

  $hadoop_confdir = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '/etc/hadoop',
    /Debian|RedHat/ => '/etc/hadoop/conf',
  }

  $oozie_homedir = '/var/lib/oozie'

  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      $packages = {
        'server' => 'oozie',
        'client' => 'oozie',
      }
    }
    /Debian|RedHat/: {
      $packages = {
        'server' => 'oozie',
        'client' => 'oozie-client',
      }
    }
    default: {
      fail("${::operatingsystem} (${::osfamily}) not supported")
    }
  }

}
