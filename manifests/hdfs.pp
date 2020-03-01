# == Class ::oozie::hdfs
#
# HDFS initializations. Actions necessary to launch on HDFS namenode: Creates oozie user, if needed. Creates directory /user/oozie on HDFS for Oozie. It needs to be called after Hadoop HDFS is working (its namenode and proper number of datanodes) and before Oozie service startup.
#
# This class is needed to be launched on one HDFS namenode. With some limitations it can be launched on any Hadoop node (user oozie created or oozie installed on namenode, kerberos ticket available on the local node).
#
class oozie::hdfs {
  include ::oozie::user

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
