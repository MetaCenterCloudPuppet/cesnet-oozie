# == Class oozie::common::config
#
# Common configuration files for oozie.
#
class oozie::common::config {
  file { "${::oozie::confdir}/oozie-site.xml":
    owner   => 'oozie',
    group   => 'oozie',
    mode    => '0640',
    content => template('oozie/oozie-site.xml.erb'),
  }

  file { "${::oozie::confdir}/oozie-env.sh":
    owner   => 'oozie',
    group   => 'oozie',
    mode    => '0600',
    content => template('oozie/oozie-env.sh.erb'),
  }
}
