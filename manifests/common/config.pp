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

  if $::oozie::https {
    $base_url = 'https://${OOZIE_HTTP_HOSTNAME}:${OOZIE_HTTPS_PORT}/oozie'
  } else {
    $base_url = 'http://${OOZIE_HTTP_HOSTNAME}:${OOZIE_HTTP_PORT}/oozie'
  }

  $env = "${::oozie::confdir}/oozie-env.sh"
  augeas { "${::oozie::confdir}/oozie-env.sh-https":
    incl    => $env,
    lens    => 'Shellvars.lns',
    changes => [
      "set /files${env}/OOZIE_HTTP_HOSTNAME '`hostname -f`'",
      "set /files${env}/OOZIE_HTTP_HOSTNAME/export ''",
      "set /files${env}/OOZIE_HTTP_PORT 11000",
      "set /files${env}/OOZIE_HTTP_PORT/export ''",
      "set /files${env}/OOZIE_HTTPS_PORT 11443",
      "set /files${env}/OOZIE_HTTPS_PORT/export ''",
      "set /files${env}/OOZIE_BASE_URL '${base_url}'",
      "set /files${env}/OOZIE_BASE_URL/export ''",
      "set /files${env}/OOZIE_HTTPS_KEYSTORE_PASS '${::oozie::_https_keystore_password}'",
      "set /files${env}/OOZIE_HTTPS_KEYSTORE_PASS/export ''",
    ],
  }
}
