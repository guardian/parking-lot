#!/bin/bash

DIR="$(cd $(dirname "$0"); pwd)/tests"

for FILE in $(find $DIR -name '*.sh'); do
    $FILE
done
