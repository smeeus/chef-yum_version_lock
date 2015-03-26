if defined?(ChefSpec)
  def yum_version_lock(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:yum_version_lock, :lock, resource_name)
  end

  def yum_version_unlock(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:yum_version_lock, :unlock, resource_name)
  end
end
