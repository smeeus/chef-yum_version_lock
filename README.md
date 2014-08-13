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
# Lock the package to the specific version. 
# If any outstanding locks exist for other versions, they are removed
yum_version_lock "package" do
  version "0.13.0-1"
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

