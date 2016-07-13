# Note for now this spec has a dep on ipam being available. Not going to execute these for a while
#
# require 'spec_helper'
#
# describe 'bind', type: :class do
#   let :facts do
#     {
#       osfamily: 'RedHat',
#       operatingsystemmajrelease: '7'
#     }
#   end
#
#   it { should contain_package('bind').with_ensure('present') }
#   it { should contain_package('bind-utils').with_ensure('present') }
#   it { should contain_package('bind-chroot').with_ensure('present') }
# end
