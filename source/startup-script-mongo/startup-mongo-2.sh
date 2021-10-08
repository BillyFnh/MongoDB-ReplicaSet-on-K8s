#!/bin/bash

mkdir -p /data/db/rs0-2

export POD_IP_ADDRESS=$(hostname -i)
mongod --replSet rs0 --port 27017 --bind_ip localhost,$POD_IP_ADDRESS --dbpath /data/db/rs0-2 --oplogSize 128 --keyFile /etc/secrets/mongokeyfile --auth