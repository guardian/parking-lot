#!/bin/bash

# Update index and install packages
cat << EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse
EOF

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install apache2

if [ ! -f /.dockerinit ]; then
    # If not in Docker
    DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install wget cloud-guest-utils python-setuptools awscli

    # Install AWS CFN bootstrap
    wget -P /tmp https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
    mkdir -p /tmp/aws-cfn-bootstrap-latest
    tar xvfz /tmp/aws-cfn-bootstrap-latest.tar.gz --strip-components=1 -C /tmp/aws-cfn-bootstrap-latest
    easy_install /tmp/aws-cfn-bootstrap-latest
    rm -fr /tmp/aws-cfn-bootstrap-latest

    # Ensure we don't swap unnecessarily
    echo "vm.overcommit_memory=1" > /etc/sysctl.d/70-vm-overcommit
fi

# Disable modules
for module in autoindex access_compat auth_basic authn_core authn_file authz_host authz_user status; do
  a2dismod $module
done

# Enable modules
for module in alias rewrite; do
  a2enmod $module
done

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
