require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

$test_os=[{
    'osfamily' => 'Debian',
    'operatingsystem' => 'Debian',
    'operatingsystemrelease' => ['7']
  }, {
    'osfamily' => 'Debian',
    'operatingsystem' => 'Ubuntu',
    'operatingsystemrelease' => ['14.04']
  }, {
    'osfamily' => 'RedHat',
    'operatingsystem' => 'RedHat',
    'operatingsystemrelease' => ['6']
  }, {
    'osfamily' => 'CentOS',
    'operatingsystem' => 'RedHat',
    'operatingsystemrelease' => ['6']
  }]

$test_config_dir={
  'CentOS' => '/etc/oozie/conf',
  'Debian' => '/etc/oozie/conf',
  'Fedora' => '/etc/oozie',
  'RedHat' => '/etc/oozie/conf',
  'Ubuntu' => '/etc/oozie/conf',
}
