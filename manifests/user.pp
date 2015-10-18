# == Class ::oozie::user
#
# Create oozie system user. The oozie user is required on the all HDFS namenodes to authorization work properly and we don't need to install oozie just for the user.
#
# It is better to handle creating the user by the packages, so we recommend dependecny on installation classes or Oozie packages.
#
class oozie::user {
  group { 'oozie':
    ensure => present,
    system => true,
  }
  case "${::osfamily}-${::operatingsystem}" {
    /RedHat-Fedora/: {
      user { 'oozie':
        ensure     => present,
        system     => true,
        comment    => 'Apache Oozie',
        gid        => 'oozie',
        home       => $::oozie::oozie_homedir,
        managehome => true,
        password   => '!!',
        shell      => '/sbin/nologin',
      }
    }
    /Debian|RedHat/: {
      user { 'oozie':
        ensure     => present,
        system     => true,
        comment    => 'Oozie User',
        gid        => 'oozie',
        home       => $::oozie::oozie_homedir,
        managehome => true,
        password   => '!!',
        shell      => '/bin/false',
      }
    }
    default: {
      notice("${::operatingsystem} (${::os_family}) not supported")
    }
  }
  Group['oozie'] -> User['oozie']
}
