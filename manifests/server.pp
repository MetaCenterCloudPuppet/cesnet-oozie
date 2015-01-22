# == Class: oozie::server

class oozie::server {
  class { '::oozie::server::install': } ->
  class { '::oozie::server::config': } ~>
  class { '::oozie::server::service': } ->
  Class['::oozie::server']
}
