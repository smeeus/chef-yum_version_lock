
actions :lock, :unlock, :track
default_action :lock

attribute :epoch, :kind_of => String
attribute :version, :kind_of => String, :required => true
attribute :release, :kind_of  => String
attribute :arch, :kind_of => String

