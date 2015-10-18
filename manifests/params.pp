# == Class oozie::params
#
# This class is meant to be called from oozie.
# It sets variables according to platform.
#
class oozie::params {
  $alternatives_ssl = "${::osfamily}-${::operatingsystem}" ? {
    /RedHat-Fedora/ => '',
    /Debian|RedHat/ => 'oozie-tomcat-deployment',
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

  $oozie_sharelib = '/usr/lib/oozie/oozie-sharelib-yarn'

  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      $packages = {
        'server' => 'oozie',
        'client' => 'oozie',
        'unzip'  => 'unzip',
      }
    }
    /Debian|RedHat/: {
      $packages = {
        'server' => 'oozie',
        'client' => 'oozie-client',
        'unzip'  => 'unzip',
      }
    }
    default: {
      fail("${::operatingsystem} (${::osfamily}) not supported")
    }
  }

}
