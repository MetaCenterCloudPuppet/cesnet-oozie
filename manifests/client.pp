# == Class oozie::client
#
class oozie::client {
  class { '::oozie::client::install': } ->
  class { '::oozie::client::config': } ->
  Class['::oozie::client']
}
