#!/bin/bash

SRC_DIR=$(cd $(dirname "$0"); pwd)
cp ${SRC_DIR}/../scripts/setup.sh .
docker build -t="parking-lot" $SRC_DIR
rm -f $SRC_DIR/setup.sh
