#!/bin/bash

mkdir -p /data/db/rs0-0
export POD_IP_ADDRESS=$(hostname -i)

if [[ $MONGO_CONFIGURE_REPLICA_SET == true ]]
then
    /root/reconfig-mongo-rs.sh &

    mongod --replSet rs0 --port 27017 --bind_ip localhost,$POD_IP_ADDRESS --dbpath /data/db/rs0-0 --oplogSize 128

    echo "POD_IP_ADDRESS: $POD_IP_ADDRESS:$MONGODB_0_SERVICE_SERVICE_PORT"
    echo "MONGODB_0_SERVICE_SERVICE_HOST: $MONGODB_0_SERVICE_SERVICE_HOST:$MONGODB_0_SERVICE_SERVICE_PORT"
    echo "MONGODB_1_SERVICE_SERVICE_HOST: $MONGODB_1_SERVICE_SERVICE_HOST:$MONGODB_1_SERVICE_SERVICE_PORT"
    echo "MONGODB_2_SERVICE_SERVICE_HOST: $MONGODB_2_SERVICE_SERVICE_HOST:$MONGODB_2_SERVICE_SERVICE_PORT"
else
    echo "Starting MongoDB as standalone instance" 
    mongod --port 27017 --bind_ip localhost,$POD_IP_ADDRESS,$MONGODB_0_SERVICE_SERVICE_HOST --dbpath /data/db/rs0-0
fi
