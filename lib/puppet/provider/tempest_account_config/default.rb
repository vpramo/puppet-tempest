require 'yaml'
Puppet::Type.type(:tempest_account_config).provide(:default) do
  def conf
    begin
      @conf ||= YAML.load(File.read(config_file))
    rescue
      @conf ||= {}
    end
  end

  def config_file
    resource[:configfile]
  end

  def username
    resource[:name].gsub(/^(\S+)@.*/,'\1')
  end

  def tenantname
    resource[:name].gsub(/^\S+@(\S+)/,'\1')
  end

  def exists?
    conf.each do |account|
      if account['username'] == username && account['tenant_name'] == tenantname
        return true
      end
    end
    return false
  end

  def create
    conf.push(
      'username'    => username,
      'tenant_name' => tenantname,
      'password'    => resource[:password],
      )
  end

  def destroy
    conf.each do |account|
      if account['username'] == username && account['tenant_name'] == tenantname
        conf.delete(
          'username'    => account['username'],
          'tenant_name' => account['tenantname'],
          'password'    => account['password'],
        )
      end
    end
  end

  def flush
    File.open(config_file, 'w') do |f|
      f.puts YAML.dump(conf)
    end
  end

  def password
    conf.each do |account|
      if account['username'] == username && account['tenant_name'] == tenantname
        return account['password']
      end
    end
  end

  def password=(value)
    conf.each do |account|
      if account['username'] == username && account['tenant_name'] == tenantname
        account['password'] = resource[:password]
      end
    end
  end

end
