require 'spec_helper'

describe 'bind::service', type: :class do
  context 'Service' do
    context 'with operatingsystemmajrelease => 6' do
      let :facts do
        {
          osfamily: 'RedHat',
          operatingsystemmajrelease: '6'
        }
      end
      it { should contain_service('named').with_ensure('running') }
      it { should_not contain_service('named-chroot').with_ensure('running') }
    end

    context 'with operatingsystemmajrelease => 7' do
      let :facts do
        {
          osfamily: 'RedHat',
          operatingsystemmajrelease: '7'
        }
      end
      it { should contain_service('named').with_ensure('stopped') }
      it { should contain_service('named-chroot').with_ensure('running') }
    end

    let :facts do
      {
        osfamily: 'RedHat',
        operatingsystemmajrelease: '6'
      }
    end
    it { should contain_exec('named_restart').with_refreshonly('true') }
    it { should contain_exec('zone_reload').with_refreshonly('true') }
    it { should contain_file('/etc/named.conf').with_owner('root') }
  end
end
