# == Class oozie::client::install
#
class oozie::client::install {
  include stdlib
  contain oozie::common::postinstall

  ensure_packages($oozie::packages['client'])

  Package[$oozie::packages['client']] -> Class['oozie::common::postinstall']
}
