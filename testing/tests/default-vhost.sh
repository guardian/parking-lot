#!/bin/bash

# Source testing framework
source $(dirname $0)/../assert.sh

# Run tests
test_return_code "default.vhost" "" "404"
test_return_code "default.vhost" "/healthcheck" "200"

# End testing
assert_end default-vhost
