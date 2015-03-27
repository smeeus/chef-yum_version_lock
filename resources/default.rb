
actions :lock, :unlock
default_action :lock

attribute :epoch, :kind_of => String
attribute :version, :kind_of => [Integer, String]
attribute :release, :kind_of => [Integer, String]
attribute :arch, :kind_of => String
attribute :even_if_not_available, :kind_of => [TrueClass, FalseClass], :default => false

