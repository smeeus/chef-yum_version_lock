
r = package "yum-plugin-versionlock" do
  action :nothing
end

if node[:yum][:versionlock][:compile_time] then r.run_action :install
else r.action :install
end

