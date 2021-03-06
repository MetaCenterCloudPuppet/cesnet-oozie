require 'spec_helper'

describe 'oozie::client::config', :type => 'class' do
  on_supported_os($test_os).each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_file('/etc/profile.d/oozie.csh') }
      it { should contain_file('/etc/profile.d/oozie.sh') }
    end
  end
end

describe 'oozie::client', :type => 'class' do
  on_supported_os($test_os).each do |os,facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      it { should compile.with_all_deps }
      it { should contain_class('oozie::client') }
      it { should contain_class('oozie::client::install') }
      it { should contain_class('oozie::client::config') }
    end
  end
end
