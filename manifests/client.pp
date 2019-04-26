# == Class oozie::client
#
# Oozie client.
#
class oozie::client {
  Class['::oozie::client::install']
  -> Class['::oozie::client::config']
  -> Class['::oozie::client']
}
