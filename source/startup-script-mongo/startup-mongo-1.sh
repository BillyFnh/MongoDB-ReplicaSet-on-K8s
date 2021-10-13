#!/bin/bash

mkdir -p /data/db/rs-1
# /root/initialize-users.sh &
export POD_IP_ADDRESS=$(hostname -i)
mongod --replSet $RS_NAME --port 27017 --bind_ip localhost,$POD_IP_ADDRESS --dbpath /data/db/rs-1 --oplogSize 128 --keyFile /etc/secrets/mongokeyfile