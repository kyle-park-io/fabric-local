#!/bin/bash

# peer
PROCESS=$(pgrep peer)
if [ -n "$PROCESS" ]; then
    echo "kill $PROCESS"
    kill -9 $PROCESS
fi
