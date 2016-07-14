require 'spec_helper_acceptance'

describe 'bind class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'works idempotently with no errors' do
      pp = <<-EOS
      class { 'bind': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe package('bind') do
      it { should be_installed }
    end

    describe package('bind-utils') do
      it { should be_installed }
    end

    describe package('bind-chroot') do
      it { should be_installed }
    end

    describe service('named') do
      it { should be_running }
    end
  end
end
