#!/bin/bash

set -e

# Fetch details
REGION=$(wget -qO- http://instance-data/latest/meta-data/placement/availability-zone | sed 's/.$//')
INSTANCE_PROFILE=$(wget -qO- http://instance-data//latest/meta-data/iam/security-credentials/)
AWS_ACCESS_KEY_ID=$(wget -qO- http://instance-data/latest/meta-data/iam/security-credentials/${INSTANCE_PROFILE} | grep AccessKeyId | cut -d':' -f2 | sed 's/[^0-9A-Z]*//g')
AWS_SECRET_ACCESS_KEY=$(wget -qO- http://instance-data/latest/meta-data/iam/security-credentials/${INSTANCE_PROFILE} | grep SecretAccessKey | cut -d':' -f2 | sed 's/[^0-9A-Za-z/+=]*//g')

# Pull down our revision information
[ -f /tmp/parking-lot-version.txt ] && rm -f /tmp/parking-lot-version.txt
aws s3 --quiet --region $REGION cp s3://parking-lot/PROD/parking-lot-version.txt /tmp/parking-lot-version.txt
BUILD_VERSION=$(cat /tmp/parking-lot-version.txt)

# Test if we're running the latest
[ -d /etc/gu ] || mkdir /etc/gu
if [ -f /etc/gu/parking-lot-version.txt ]; then
    CURRENT_VERSION=$(cat /etc/gu/parking-lot-version.txt)
    [ "$BUILD_VERSION" == "$CURRENT_VERSION" ] && exit 0
fi

# Pull down new apache config
aws s3 --quiet --region $REGION cp s3://parking-lot/PROD/parking-lot.tar.gz /tmp/parking-lot.tar.gz
tar -zxf /tmp/parking-lot.tar.gz -C /tmp

# Apply config
[ -d /etc/apache2/sites-enabled.backup ] && rm -rf /etc/apache2/sites-enabled.backup
mv /etc/apache2/sites-enabled /etc/apache2/sites-enabled.backup
mv /tmp/parking-lot/sites /etc/apache2/sites-enabled

# Test and restart
CONFIG_TEST=$(apachectl -t 2>&1)
RESTART=$(service apache2 restart 2>&1)

# Set running build version
mv /tmp/parking-lot-version.txt /etc/gu/parking-lot-version.txt

# Also copy the git revision to our healthcheck path
cp /etc/gu/parking-lot-version.txt /var/www/html/healthcheck
