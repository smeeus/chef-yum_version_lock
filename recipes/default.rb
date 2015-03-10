
r = package "yum-plugin-versionlock" do
  action :nothing
end

if node[:yum][:versionlock][:compile_time] then r.run_action :upgrade
else r.action :upgrade
end

#begin
#  include_recipe "build-essential::_#{node['platform_family']}"
#rescue Chef::Exceptions::RecipeNotFound
#  Chef::Log.warn <<-EOH
#A build-essential recipe does not exist for '#{node['platform_family']}'. This
#means the build-essential cookbook does not have support for the
##{node['platform_family']} family. If you are not compiling gems with native
#extensions or building packages from source, this will likely not affect you.
#EOH
#end

