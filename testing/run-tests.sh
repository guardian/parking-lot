#!/bin/bash

DIR="$(cd $(dirname "$0"); pwd)/tests"

exit_code=0
for FILE in $(find $DIR -name '*.sh'); do
    $FILE
    [ $? -gt 0 ] && exit_code=1
done

exit $exit_code
