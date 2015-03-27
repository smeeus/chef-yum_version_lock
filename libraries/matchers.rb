if defined?(ChefSpec)
  def lock_yum_version(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:yum_version_lock, :lock, resource_name)
  end

  def unlock_yum_version(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:yum_version_lock, :unlock, resource_name)
  end
end
