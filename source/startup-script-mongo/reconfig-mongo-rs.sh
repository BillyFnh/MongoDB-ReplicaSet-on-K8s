#!/bin/bash

retryCount=0

echo "Checking MongoDB status:"

while [[ "$(mongo --quiet --eval "rs.status().ok")" != "0" ]]
do
    if [ $retryCount -gt 30 ]
    then
        echo "Retry count > 30, breaking out of while loop now..."
        break
    fi
    echo "MongoDB not ready for Replica Set configuration, retrying in 5 seconds..."
    sleep 5
    retryCount=$((retryCount+1))
done

echo "Sending in Replica Set configuration..."

mongo --eval "mongodb = ['$MONGODB_0_SERVICE_SERVICE_HOST:$MONGODB_0_SERVICE_SERVICE_PORT', '$MONGODB_1_SERVICE_SERVICE_HOST:$MONGODB_1_SERVICE_SERVICE_PORT', '$MONGODB_2_SERVICE_SERVICE_HOST:$MONGODB_2_SERVICE_SERVICE_PORT']" -u clusterAdmin -p $MONGODB_ADMIN_PASSWORD --shell << EOL
cfg = rs.conf()
cfg.members[0].host = mongodb[0]
cfg.members[1].host = mongodb[1]
cfg.members[2].host = mongodb[2]
rs.reconfig(cfg, {force: true})
EOL

sleep 5

if [[ $(mongo --quiet --eval "db.isMaster().setName") != $RS_NAME ]]
then
    echo "Replica Set reconfiguratoin failed..."
    echo "Reinitializing Replica Set..."
    /root/initialize-mongo-rs.sh &
else
    echo "Replica Set reconfiguratoin successful..."
fi