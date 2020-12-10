# == Class oozie::client
#
# Oozie client.
#
class oozie::client {
  include ::oozie::client::install
  include ::oozie::client::config

  Class['oozie::client::install']
  -> Class['oozie::client::config']
  -> Class['oozie::client']
}
