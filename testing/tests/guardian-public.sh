#!/bin/bash

# Source testing framework
source $(dirname $0)/../assert.sh

# Run tests
test_redirect "www.guardianpublic.co.uk" "" "http://www.theguardian.com/public-leaders-network"
test_redirect "www.guardianpublic.com" "" "http://www.theguardian.com/public-leaders-network"
test_redirect "guardianpublic.co.uk" "" "http://www.theguardian.com/public-leaders-network"
test_redirect "guardianpublic.com" "" "http://www.theguardian.com/public-leaders-network"

# End testing
assert_end guardian-public
