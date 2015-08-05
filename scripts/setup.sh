#!/bin/bash

set -e

# Update index and install packages
cat << EOF > /etc/apt/sources.list
deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu/ trusty-updates main restricted universe multiverse
EOF

# Need a short sleep here, or apt doesn't pick up the updated sources
sleep 2
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install apache2

if [ ! -f /.dockerinit ]; then
    # If not in Docker
    DEBIAN_FRONTEND=noninteractive apt-get --yes --force-yes install wget cloud-guest-utils python-setuptools awscli

    # Install AWS CFN bootstrap
    wget -P /tmp https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
    mkdir -p /tmp/aws-cfn-bootstrap-latest
    tar xfz /tmp/aws-cfn-bootstrap-latest.tar.gz --strip-components=1 -C /tmp/aws-cfn-bootstrap-latest
    easy_install /tmp/aws-cfn-bootstrap-latest
    rm -fr /tmp/aws-cfn-bootstrap-latest

    # Ensure we don't swap unnecessarily
    echo "vm.overcommit_memory=1" > /etc/sysctl.d/70-vm-overcommit

    # Sync script
    cp /tmp/scripts/parking-lot-sync.sh /usr/local/sbin/parking-lot-sync
    cp /tmp/scripts/parking-lot-sync.cron /etc/cron.d/parking-lot-sync
fi

# Disable modules
for module in autoindex access_compat auth_basic authn_core authn_file authz_host authz_user status; do
  a2dismod $module
done

# Enable modules
for module in alias rewrite; do
  a2enmod $module
done

# Add initial healthcheck file
echo 'Not yet provisioned' > /var/www/html/healthcheck

# Clean up
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -fr /tmp/scripts
