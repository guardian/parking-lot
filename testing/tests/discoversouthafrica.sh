#!/bin/bash

# Source testing framework
source $(dirname $0)/../assert.sh

# Run tests
test_redirect "discoversouthafrica.theguardian.com" ""          "http://www.theguardian.com/info/2015/feb/06/paid-content-removal-policy"
test_redirect "discoversouthafrica.theguardian.com" "/anything" "http://www.theguardian.com/info/2015/feb/06/paid-content-removal-policy"

# End testing
assert_end discoversouthafrica
