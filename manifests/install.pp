# == Class oozie::install
#
# This class is called from oozie for install.
#
class oozie::install {

  package { $::oozie::package_name:
    ensure => present,
  }
}
