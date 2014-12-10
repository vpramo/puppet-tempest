Puppet::Type.newtype(:tempest_account_config) do
  @doc = "This type is to configure tempest accounts.yaml
it accept following parameters
configfile: accounts.yaml path.
password: keystone password for tempest user

Note:
This support keystone v2 at this moment, it may need more details like domain to
be added to work with keystone v3.
"
  ensurable

  newparam(:name, :namevar => true) do
    desc 'This the username to be configured, and must be in the form of <username>@<tenant_name>'
    newvalues(/\S+@\S+/)
  end

  newparam(:configfile) do
    desc 'File path of the tempest accounts.yaml file'
    newvalues(/[\/\S]+/)
    defaultto '/etc/tempest/accounts.yaml'
    validate do |val|
      unless Pathname.new(val).absolute?
        fail("Invalid account configuration file path #{val}")
      end
    end
  end

  newproperty(:password) do
    desc 'Keystone password'
    newvalues(/^[\S ]*$/)

    def is_to_s( currentvalue )
      return '[old secret redacted]'
    end

    def should_to_s( newvalue )
      return '[new secret redacted]'
    end
  end

  validate do
    raise(Puppet::Error, 'password is required') unless self[:password]
  end

end
