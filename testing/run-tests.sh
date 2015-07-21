#!/bin/bash

run-parts --regex '^.*sh$' $(dirname $0)/tests
