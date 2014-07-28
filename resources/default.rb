
actions :lock, :unlock, :track
default_action :lock

attribute :source,  :kind_of => String, :name_attribute => true
attribute :version, :kind_of => String, :required => true
attribute :release, :kind_of => String

