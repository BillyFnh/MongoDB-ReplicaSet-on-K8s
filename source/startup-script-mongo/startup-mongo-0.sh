#!/bin/bash

mkdir -p /data/db/rs-0
export POD_IP_ADDRESS=$(hostname -i)

/root/reconfig-mongo-rs.sh &

mongod --replSet $RS_NAME --port 27017 --bind_ip localhost,$POD_IP_ADDRESS --dbpath /data/db/rs-0 --oplogSize 128 --keyFile /etc/secrets/mongokeyfile
