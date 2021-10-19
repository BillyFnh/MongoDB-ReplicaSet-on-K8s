import os
import urllib

from pymongo import MongoClient

username=urllib.parse.quote_plus(os.environ.get('MONGODB_USER'))
password=urllib.parse.quote_plus(os.environ.get('MONGODB_PASSWORD'))

url='mongodb://%s:%s@mongo-cms-fcmki4ox2hnr-node-0.cern.ch:32001,mongo-cms-fcmki4ox2hnr-node-0.cern.ch:32002,mongo-cms-fcmki4ox2hnr-node-0.cern.ch:32003/admin?replicaSet=cms-db1' % (username, password)
client = MongoClient(url)
print(client.admin.command('replSetGetStatus'))
