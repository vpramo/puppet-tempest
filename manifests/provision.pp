#
# Class tempest::provision
# Help provisioning the openstack resources like image, network, etc.
# Taken from puppet-openstack/provision.pp
#   https://github.com/stackforge/puppet-openstack/blob/master/manifests/provision.pp
#
class tempest::provision (
  $image_public     = 'yes',
  $image_source     = 'http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img',
  $imagename        = undef,
  $alt_image_source = undef,
  $alt_imagename    = undef,
  $tenantname       = undef,
  $username         = undef,
  $password         = 'tempest_pass',
  $admin_username   = undef,
  $admin_password   = 'tempest_admin_pass',
  $networkname      = undef,
  $subnetname       = 'sn_tempest',
  $subnetcidr       = '10.0.0.0/24',
  $alt_tenantname   = undef,
  $alt_username     = undef,
  $alt_password     = undef,
  $user_extra_roles = ['Member','ResellerAdmin'],
  $container_format = 'bare',
  $disk_format      = 'qcow2',
) {

  ##
  # Create required resources in order to run tempest
  ##

  if $tenantname {
    keystone_tenant { $tenantname:
      ensure      => present,
      enabled     => true,
      description => 'tempest tenant',
    }
  }

  if $username {
    if ! $tenantname {
      fail('Tenant name is required to create keystone user')
    }


    keystone_role {$user_extra_roles:
      ensure => present,
    }

    keystone_user { $username:
      ensure      => present,
      enabled     => true,
      tenant      => $tenantname,
      password    => $password,
    }

    $user_roles = concat($user_extra_roles,['_member_'])

    keystone_user_role {"${username}@${tenantname}":
      roles   => [$user_roles],
      require => Keystone_role[$user_extra_roles],
    }
  }

  if $admin_username {

    if ! $tenantname {
      fail('Tenant name is required to create keystone user')
    }

    keystone_user { $admin_username:
      ensure      => present,
      enabled     => true,
      tenant      => $tenantname,
      password    => $admin_password,
    }

    keystone_user_role {"${admin_username}@${tenantname}":
      roles  => ['admin'],
      ensure => present,
    }
  }


  if $alt_tenant_name {
    keystone_tenant { $alt_tenant_name:
      ensure      => present,
      enabled     => true,
      description => 'alt tenant',
    }

    keystone_user { $alt_username:
      ensure      => present,
      enabled     => true,
      tenant      => $alt_tenant_name,
      password    => $alt_password,
    }
  }


  if $imagename {
    glance_image { $imagename:
      ensure           => present,
      is_public        => $image_public,
      container_format => $container_format,
      disk_format      => $disk_format,
      source           => $image_source,
    }
  }

  if ($alt_imagename) and  ($alt_image_source) {
    glance_image { $alt_imagename:
      ensure           => present,
      is_public        => $image_public,
      container_format => $container_format,
      disk_format      => $disk_format,
      source           => $alt_image_source,
    }
  }

  if $networkname {
    neutron_network { $networkname:
      ensure          => present,
      tenant_name     => $tenantname,
    }

    if $subnetname {
      neutron_subnet { $subnetname:
        ensure          => 'present',
        cidr            => $subnetcidr,
        network_name    => $networkname,
        tenant_name     => $tenantname,
      }
    }
  }
}

