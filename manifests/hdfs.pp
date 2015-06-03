# == Class ::oozie::hdfs
#
# HDFS initialiations. Actions necessary to launch on HDFS namenode: Create oozie user, if needed. Creates directory /user/oozie on HDFS for Oozie. It needs to be called after Hadoop HDFS is working (its namenode and proper number of datanodes) and before Oozie service startup.
#
# This class is needed to be launched on HDFS namenode. With some limitations it can be launched on any Hadoop node (user oozie created or oozie installed on namenode, kerberos ticket available on the local node).
#
class oozie::hdfs {
  include stdlib

  validate_string($::oozie::_defaultFS)

  # create user/group if needed (we don't need to install oozie just for user, unless it is collocated with the namenode)
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

  $touchfile = 'oozie-dir-created'
  hadoop::kinit { 'oozie-kinit':
    touchfile => $touchfile,
  }
  ->
  hadoop::mkdir { '/user/oozie':
    mode      => '0755',
    owner     => 'oozie',
    group     => 'oozie',
    touchfile => $touchfile,
  }
  ->
  hadoop::kdestroy { 'oozie-kdestroy':
    touchfile => $touchfile,
    touch     => true,
  }
}
