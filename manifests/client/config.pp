class oozie::client::config {
  $realm = $oozie::realm

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
