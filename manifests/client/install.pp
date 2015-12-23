# == Class oozie::client::install
#
class oozie::client::install {
  include ::stdlib

  ensure_packages($oozie::packages['client'])
}
