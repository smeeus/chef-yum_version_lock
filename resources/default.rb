
actions :lock, :unlock, :track
default_action :lock

attribute :version, :kind_of => String, :required => true
attribute :release, :kind_of => String

