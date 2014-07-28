# yum_version_lock-cookbook

Provides a LWRP to allow pinning yum package versions

## Supported Platforms

centos
amazon
fedora

## Usage

### yum_version_lock::default

Install the yum-plugin-versionlock plugin

### LWRP

```
# Lock the package to the current installed version unless a lock exists for
# any other version of this package
yum_version_lock "package" do
  action :lock
end
```

```
# Lock the package to the current installed version unless a lock exists for
# the version specified
yum_version_lock "package" do
  version "1.0.0"
  action :lock
end
```

```
# Remove all version locks matching supplied attributes
yum_version_lock "package" do
  action :unlock
end

yum_version_lock "package" do
  version "1.0.0"
  action :unlock
end
```

```
# Or to track the installed state of a package
# when a package is already installed, this will :lock
# when a package is not installed, this will :unlock
yum_version_lock "package" do
  action :track
end
```

