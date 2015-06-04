require 'spec_helper'

describe 'oozie::server::config', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']
    path = $test_config_dir[os]

    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_file(path + '/oozie-site.xml') }
    end
  end
end

describe 'oozie::server', :type => 'class' do
  $test_os.each do |facts|
    os = facts['operatingsystem']
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { should compile.with_all_deps }
      it { should contain_class('oozie::common::config') }
      it { should contain_class('oozie::server::install') }
      it { should contain_class('oozie::server::config') }
      it { should contain_class('oozie::server::service') }
    end
  end
end