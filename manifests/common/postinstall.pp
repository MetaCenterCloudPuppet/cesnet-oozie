# == Class oozie::common::postinstall
#
# Preparation steps after installation. It switches oozie-conf alternative, if enabled.
#
class oozie::common::postinstall {
  ::hadoop_lib::postinstall{ 'oozie':
    alternatives => $::oozie::alternatives
  }
}
