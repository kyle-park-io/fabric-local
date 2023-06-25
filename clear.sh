#!/bin/bash

# log
rm -rf log
mkdir log

# production
rm -rf production

docker rm -f $(docker ps -aq)
docker rmi $(docker images -q --filter "reference=dev-*")

# ca
PROCESS=$(pgrep fabric-ca)
if [ -n "$PROCESS" ]; then
    echo "kill $PROCESS"
    kill -9 $PROCESS
fi

# orderer
PROCESS=$(pgrep orderer)
if [ -n "$PROCESS" ]; then
    echo "kill $PROCESS"
    kill -9 $PROCESS
fi

# peer
PROCESS=$(pgrep peer)
if [ -n "$PROCESS" ]; then
    echo "kill $PROCESS"
    kill -9 $PROCESS
fi
