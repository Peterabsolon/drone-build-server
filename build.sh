#!/bin/bash

VERSION="$1"

if [ "$VERSION" == "" ]; then
    echo "VERSION parameter missing"
    exit 1
fi

cp ~/.ssh/id_rsa secrets/

docker build -t peterabsolon/build-server:$VERSION .

docker push peterabsolon/build-server:$VERSION
