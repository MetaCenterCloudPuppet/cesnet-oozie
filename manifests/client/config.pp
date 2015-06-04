# == Class oozie::client::config
#
# Oozie client setup. Shell profile files are created or removed.
#
class oozie::client::config {
  $oozie_hostname = $::oozie::oozie_hostname
  $https = $::oozie::https

  if $oozie::environment {
    file{'/etc/profile.d/oozie.csh':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('oozie/oozie.csh.erb'),
    }
    file{'/etc/profile.d/oozie.sh':
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('oozie/oozie.sh.erb'),
    }
  } else {
    file{'/etc/profile.d/oozie.csh':
      ensure => 'absent',
    }
    file{'/etc/profile.d/oozie.sh':
      ensure => 'absent',
    }
  }
}
