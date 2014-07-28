
use_inline_resources

def load_current_resource
  if new_resource.release.nil?
    version, release = new_resource.version.split('-')

    unless release.nil?
      new_resource.version version
      new_resource.release release
    end
  end
end

def version_file
  node[:yum][:versionlock][:file]
end

def hash_from_spec s
  if match = s.match(/^(\d+):(.+)-(.+)-(.+).(.+)$/)
    epoch, name, version, release, arch = match.captures
    { 
      :name => name,
      :epoch => epoch,
      :version => version, 
      :release => release, 
      :arch => arch 
    }
  end
end

def hash_from_resource
  { 
    :name => new_resource.source || new_resource.name,
    :version => new_resource.version,
    :release => new_resource.release
  }.reject { |k,v| v.nil? }
end

def spec_from_hash h
  "#{h[:epoch]}:#{h[:name]}-#{h[:version]}-#{h[:release]}.#{h[:arch]}"
end

def version_locks
  @version_locks = [] unless ::File.exist? version_file
  @version_locks ||= begin
    parsed_data = []                   
    open(version_file) do |io|
      io.each_line do |line|
        next if line =~ /^\s*(#.*)?$/
        next unless hash = hash_from_spec(line)
        parsed_data << hash
      end
    end
    parsed_data
  end
end

def version_locks_for_hash opts={}
  version_locks.select do |data|
    opts.all? { |k,v| data[k] == v }
  end
end

def version_locks_for_resource
  version_locks_for_hash hash_from_resource
end

action :lock do
  execute "yum versionlock add #{new_resource.source || new_resource.name}" do
    only_if { version_locks_for_resource.empty? }
    action :nothing
  end.run_action :run
end

action :unlock do
  version_locks_for_resource.uniq.each do |hash|
    execute "yum versionlock delete #{spec_from_hash hash}" do
      action :nothing
    end.run_action :run
  end
end

action :track do
  package_installed = `rpm -qa | grep #{new_resource.source || new_resource.name}`
  package_installed.empty? ? action_unlock : action_lock
end

