
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
  if new_resource.release.nil?
    version, release = new_resource.version.split('-')
  else
    version = new_resource.version
    release = new_resource.release
  end
  { 
    :name => name,
    :version => version,
    :release => release
  }.reject { |k,v| v.nil? }
end

def spec_from_hash h
  s = ""
  s << "#{h[:epoch]}:" if h[:epoch]
  s << "#{h[:name]}-#{h[:version]}-#{h[:release] || 1}"
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

    # debugging
    puts "version_locks - parsed_data: #{parsed_data}"

    parsed_data
  end
end

def version_locks_for_hash opts={}

  # debugging
  puts "version_locks_for_hash - opts: #{opts}"

  ret = version_locks.select do |data|
    opts.all? { |k,v| data[k] == v }
  end

  # debugging
  puts "version_locks_for_hash - ret: #{ret}"

  ret
end

def version_locks_for_resource
  version_locks_for_hash hash_from_resource
end

def version_locks_outstanding
  resource_hash = hash_from_resource
  resource_hash.delete :version
  resource_hash.delete :release

  version_locks_for_hash(resource_hash).select do |hash|

#    # debugging
#    puts "version_locks_outstanding - version_locks_for_hash(resource_hash).select: #{hash}"
#    puts "version_locks_outstanding - new_resource.version: #{new_resource.version}"
#    puts "version_locks_outstanding - new_resource.release: #{new_resource.release}"

    next if hash[:version] == new_resource.version

#    # debugging
#    puts "version_locks_outstanding - next if hash[:version] == new_resource.version"

    if hash[:version] == new_resource.version

#      # debugging
#      puts "version_locks_outstanding - if hash[:version] == new_resource.version"

      if new_resource.release and hash[:release]

#        # debugging
#        puts "version_locks_outstanding - if new_resource.release and hash[:release]"

        next if hash[:release] == new_resource.release

#        # debugging
#        puts "version_locks_outstanding - next if hash[:release] == new_resource.release"

      end
    end
    
#    # debugging
#    puts "version_locks_outstanding - true"

    true
  end

end

action :lock do
  puts ""
  puts ""

  # debugging
  puts "action :lock - version_locks_outstanding: #{version_locks_outstanding}"

  # Unlock outstanding version locks
  version_locks_outstanding.uniq.each do |hash|

    # debugging
    puts "action :lock - version_locks_outstanding.uniq.each: #{hash}"
    puts "action :lock - spec_from_hash hash: #{spec_from_hash hash}"

    execute "yum versionlock delete #{spec_from_hash hash}" do
      action :nothing
    end.run_action :run
    new_resource.updated_by_last_action true
  end

  # debugging
  puts "action :lock - version_locks_for_resource.empty?: #{version_locks_for_resource}"

  # Lock current version if not locked
  if version_locks_for_resource.empty?

    # debugging
    puts "action :lock - spec_from_hash hash_from_resource: #{spec_from_hash hash_from_resource}"

    execute "yum versionlock add #{spec_from_hash hash_from_resource}" do
      action :nothing
    end.run_action :run
    new_resource.updated_by_last_action true
  end
end

action :unlock do
  puts ""
  puts ""

  # Remove locks matching attributes supplied
  version_locks_for_resource.uniq.each do |hash|
    execute "yum versionlock delete #{spec_from_hash hash}" do
      action :nothing
    end.run_action :run
    new_resource.updated_by_last_action true
  end
end

