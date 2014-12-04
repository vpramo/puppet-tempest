require 'spec_helper'

describe 'tempest::provision' do
  context 'with defaults' do
    it do
      should have_resource_count(0)
    end
  end

  context 'with params' do
    let :params do
      {
        :imagename      => 'cirros',
        :tenantname     => 'tempest',
        :username       => 'tempest',
        :admin_username => 'tempest_admin',
        :networkname    => 'n1_tempest',
        :subnetname     => 'sn1_tempest',
      }
      end

    it do
      should contain_keystone_tenant('tempest').with({
        :ensure      => 'present',
        :enabled     => true,
        :description => 'tempest tenant',
      })

      should contain_keystone_user('tempest').with({
        :ensure      => 'present',
        :enabled     => true,
        :tenant      => 'tempest',
        :password    => 'tempest_pass',
      })

      should contain_keystone_user('tempest_admin').with({
        :ensure      => 'present',
        :enabled     => true,
        :tenant      => 'tempest',
        :password    => 'tempest_admin_pass',
      })

      should contain_keystone_user_role('tempest_admin@tempest').with({
        :roles  => ['admin'],
        :ensure => 'present',
      })

      should contain_keystone_user_role('tempest@tempest').with({
        :roles  => ['_member_'],
      })

      should contain_glance_image('cirros').with({
        :ensure           => 'present',
        :is_public        => 'yes',
        :container_format => 'bare',
        :disk_format      => 'qcow2',
        :source           => 'http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img',
      })

      should contain_neutron_network('n1_tempest').with({
        :ensure          => 'present',
        :tenant_name     => 'tempest',
      })

      should contain_neutron_subnet('sn1_tempest').with({
        :ensure          => 'present',
        :cidr            => '10.0.0.0/24',
        :network_name    => 'n1_tempest',
        :tenant_name     => 'tempest',
      })

    end
  end
end
