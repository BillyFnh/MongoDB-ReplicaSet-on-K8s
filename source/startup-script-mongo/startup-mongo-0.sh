#!/bin/bash

mkdir -p /data/db/rs0-0
export POD_IP_ADDRESS=$(hostname -i)

/root/reconfig-mongo-rs.sh &

mongod --replSet rs0 --port 27017 --bind_ip localhost,$POD_IP_ADDRESS --dbpath /data/db/rs0-0 --oplogSize 128 --keyFile /etc/secrets/mongokeyfile
