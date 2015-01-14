# == Class oozie::service
#
# This class is meant to be called from oozie.
# It ensure the service is running.
#
class oozie::service {

  service { $::oozie::service_name:
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
