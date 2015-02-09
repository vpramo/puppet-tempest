Puppet::Type.type(:tempest_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:ini_setting).provider(:ruby)
) do

  def section
    resource[:name].split('/', 2).first
  end

  def setting
    resource[:name].split('/', 2).last
  end

  def separator
    '='
  end

  def glance_image_id
    @image_id ||= Puppet::Resource.indirection.find("Glance_image/#{resource[:value]}")[:id]
    @image_id if @image_id != :absent
  end

  def network_id
    @network_id ||= Puppet::Resource.indirection.find("Neutron_network/#{resource[:value]}")[:id]
    @network_id if @network_id != :absent
  end

  def flavor_id
    @flavor_id ||= Puppet::Resource.indirection.find("Nova_flavor/#{resource[:value]}")[:id]
    @flavor_id if @flavor_id != :absent
  end

  def getval
    if @val
      return @val
    end
    if ! resource[:set_id]
      @val = resource[:value]
    elsif resource[:set_id] == 'glance_image'
      @val = glance_image_id
    elsif resource[:set_id] == 'network'
      @val = network_id
    elsif resource[:set_id] == 'flavor'
      @val = flavor_id
    end
    return @val
  end

  def create
    ini_file.set_value(section, setting, getval)
    ini_file.save
    @ini_file = nil
  end

  def value
    if ini_file.get_value(section, setting) == getval
      return resource[:value]
    end
  end

  def value=(value)
    ini_file.set_value(section, setting, getval)
    ini_file.save
  end

end
