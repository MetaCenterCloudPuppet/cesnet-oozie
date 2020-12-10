# == Class: oozie::server
#
# Oozie server.
#
class oozie::server {
  include ::oozie::server::install
  include ::oozie::server::config
  include ::oozie::server::db
  include ::oozie::server::service

  Class['oozie::server::install']
  -> Class['oozie::server::config']
  ~> Class['oozie::server::service']
  -> Class['oozie::server']

  Class['oozie::server::db']
  ~> Class['oozie::server::service']
}
