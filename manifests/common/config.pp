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
    owner => 'oozie',
    group => 'oozie',
    mode  => '0600',
  }

  $env = "${::oozie::confdir}/oozie-env.sh"
  augeas { "${::oozie::confdir}/oozie-env.sh-https":
    incl    => $env,
    lens    => 'Shellvars.lns',
    changes => [
      "set /files${env}/OOZIE_HTTPS_PORT 11443",
      "set /files${env}/OOZIE_HTTPS_PORT/export ''",
      "set /files${env}/OOZIE_HTTPS_KEYSTORE_PASS '${::oozie::https_keystore_password}'",
      "set /files${env}/OOZIE_HTTPS_KEYSTORE_PASS/export ''",
    ],
  }
}
