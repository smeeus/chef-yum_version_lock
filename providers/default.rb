
use_inline_resources

def load_current_resource
  if new_resource.epoch.nil?
    new_resource.epoch '0'
  end
  if new_resource.release.nil?
    version, release = new_resource.version.split('-')

    unless release.nil?
      new_resource.version version
      new_resource.release release
    else
      new_resource.version version
      new_resource.release '*'
    end
  end
  if new_resource.arch.nil?
    new_resource.arch '*'
  end
end

def version_file
  node[:yum][:versionlock][:file]
end

#
# To-From
#

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
  name = new_resource.name
  if new_resource.epoch.nil?
    epoch = '0'
  else
    epoch = new_resource.epoch
  end
  if new_resource.release.nil?
    version, release = new_resource.version.split('-')

    unless release.nil?
      new_resource.version version
      new_resource.release release
    else
      new_resource.version version
      new_resource.release '*'
    end
  else
    version = new_resource.version
    release = new_resource.release
  end
  if new_resource.arch.nil?
    arch = '*'
  else
    arch = new_resource.arch
  end
  { 
    :name => name,
    :epoch => epoch,
    :version => version,
    :release => release,
    :arch => arch
  }.reject { |k,v| v.nil? }
end

def spec_from_hash h
  s = ""
  s << "#{h[:epoch] || "0"}:"
  s << "#{h[:name]}-"
  s << "#{h[:version] || "*"}-"
  s << "#{h[:release] || "*"}"
  s << ".#{h[:arch] || "*" }"
  s
end


#
# Lock listing
#

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

def version_locks_outstanding
  resource_hash = hash_from_resource
  resource_hash.delete :epoch
  resource_hash.delete :version
  resource_hash.delete :release
  resource_hash.delete :arch

  version_locks_for_hash(resource_hash).select do |hash|
    donext = true

    if new_resource.version and hash[:version]
      if hash[:version] != new_resource.version
        donext = false 
      end
    else
      if new_resource.release and hash[:release]
        if hash[:release] != new_resource.release
          donext = false
        end
      else
        if new_resource.epoch and hash[:epoch]
          if hash[:epoch] != new_resource.epoch
            donext = false 
          end
        else
          if new_resource.arch and hash[:arch]
            if hash[:arch] != new_resource.arch
              donext = false 
            end
          else
            donext = false
          end
        end
      end
    end

    next if donext

    true
  end

end


action :lock do
  # Unlock outstanding version locks
  version_locks_outstanding.uniq.each do |hash|
    execute "yum versionlock delete #{spec_from_hash hash}" do
      action :nothing
    end.run_action :run
    new_resource.updated_by_last_action true
  end
  # Lock current version if not locked
  if version_locks_for_resource.empty?
    execute "yum versionlock add #{spec_from_hash hash_from_resource}" do
      action :nothing
      only_if "yum list #{new_resource.name} | grep #{new_resource.name}"
    end.run_action :run
    execute "echo \"#{spec_from_hash hash_from_resource}\" >> #{version_file}" do
      action :nothing
      not_if "yum list #{new_resource.name} | grep #{new_resource.name}"
    end.run_action :run
    new_resource.updated_by_last_action true
  end
end

action :unlock do
  # Remove locks matching attributes supplied
  version_locks_for_resource.uniq.each do |hash|
    execute "yum versionlock delete #{spec_from_hash hash}" do
      action :nothing
    end.run_action :run
    new_resource.updated_by_last_action true
  end
end

