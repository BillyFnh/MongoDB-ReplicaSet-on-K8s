# MongoDB ReplicaSet On K8s

This project containers all necessary files to launch a MongoDB ReplicaSet with 3 Mongo instances on a K8s cluster.

Here are some files you can find in this project:

- **Helm chart** (for easy launching on K8s)
- **Dockerfile** (based on official MongoDB image version 4.2.3, with custom startup scripts)
- **Custom startup scripts** (for copying into Docker image)
- **K8s manifest** (for those of you who wants to build on top of the current resources definition)
  
For more information on how this replicaset is formed, please refer to this [article](https://medium.com/swlh/how-to-setup-mongodb-replica-set-on-kubernetes-in-minutes-5c1e7fd5b5f3).

****

## Configuring Persistent Volume

This Helm Chart is developed on the CERN cloud. It uses by default the `geneva-cephfs-testing` storage class. 

If you want to deploy on another cloud provider, or use another StorageClass, you will need to change the storageClass updating `values.yaml` (`./helm-chart/values.yaml`).

****

## Launching MongoDB ReplicaSet

Using Helm, you can launch the application with the the following command, but first you need to create a namespace for the monitoring tools:

```bash
kubectl create namespace monitoring
```

```bash
helm install mongodb --set db.auth.password='xxx' --set db.auth.keyfile="$(openssl rand -base64 756)" --set db.rsname='rsName' --set db.nodeHostname='something-node-0.cern.ch' . 
```
The db.auth.password argument is the password for both the `usersAdmin` and `clusterAdmin` users.
The db.auth.keyfile is the keyfile that mongo needs to enable authentication. The `openssl rand -base64 756` command generates a random file.
The db.rsname is the name of the replica set. This is an optional argument, by default the name of the replicaset is `cms-rs`.
The db.nodeHostname is the hostname of a k8s node. This is used to configure the replicaset using the node hostname and the ports 32001, 32002 and 32003.

You should see the deploy confirmation message similar to below:

```plain
NAME: mongo
LAST DEPLOYED: Wed Oct 13 09:21:42 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Give this deployment aronud 2-3 minutes to initiate, it will do the following:

- Schedule Pods to Node
- Start `Persistent Volume` and attach Pod to `Persistent Volume` via `Persistent Volume Claim`
- Pull image from DockerHub
- Start Containers
- Start `Mongod` and initiate `ReplicaSet`
- Create `usersAdmin` and `clusterAdmin` users
- Deploy `prometheus`, `prometheus-adapter`, `kube-eagle` and `mongodb-exporter` tools for monitoring

****

## Verifying Launch Status

You can verify the K8s resources status with the this command:

```bash
kubectl get all -n default # -n is the namespace
```

Example Output - In the processing of launching:

```plain
NAME                             READY   STATUS              RESTARTS   AGE
pod/mongodb-0-9b8c6f869-pnfqk    0/1     ContainerCreating   0          1s
pod/mongodb-1-658f95995d-j26zp   0/1     ContainerCreating   0          1s
pod/mongodb-2-6cbb444455-jj6w9   0/1     ContainerCreating   0          1s

NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
service/kubernetes          ClusterIP   10.0.0.1       <none>        443/TCP     30m
service/mongodb-0-service   NodePort    10.254.108.76    <none>        27017:32001/TCP   1s
service/mongodb-1-service   NodePort    10.254.186.152   <none>        27017:32002/TCP   1s
service/mongodb-2-service   NodePort    10.254.140.157   <none>        27017:32003/TCP   1s
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mongodb-0   0/1     1            0           1s
deployment.apps/mongodb-1   0/1     1            0           1s
deployment.apps/mongodb-2   0/1     1            0           1s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/mongodb-0-9b8c6f869    1         1         0       1s
replicaset.apps/mongodb-1-658f95995d   1         1         0       1s
replicaset.apps/mongodb-2-6cbb444455   1         1         0       1s
```

Example Output - Launching completed:

```plain
NAME                             READY   STATUS              RESTARTS   AGE
pod/mongodb-0-9b8c6f869-pnfqk    1/1     Running             1          20s
pod/mongodb-1-658f95995d-j26zp   1/1     Running             1          20s
pod/mongodb-2-6cbb444455-jj6w9   1/1     Running             1          20s

NAME                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)     AGE
service/kubernetes          ClusterIP   10.0.0.1       <none>        443/TCP     30m
service/mongodb-0-service   NodePort    10.254.108.76    <none>        27017:32001/TCP   20s
service/mongodb-1-service   NodePort    10.254.186.152   <none>        27017:32002/TCP   20s
service/mongodb-2-service   NodePort    10.254.140.157   <none>        27017:32003/TCP   20s
NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mongodb-0   1/1     1            1           20s
deployment.apps/mongodb-1   1/1     1            1           20s
deployment.apps/mongodb-2   1/1     1            1           20s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/mongodb-0-9b8c6f869    1         1         1       20s
replicaset.apps/mongodb-1-658f95995d   1         1         1       20s
replicaset.apps/mongodb-2-6cbb444455   1         1         1       20s
```

You can verify the monitoring status with the this command:

```bash
kubectl get all -n monitoring
```

You can check the MongoDB ReplicaSet status by via Mongo Shell:

```bash
kubectl exec -it -n default <pod-name> mongo -u clusterAdmin -p password
# <pod-name> is the name of pod, for example it could be pod/mongodb-0-7d44df6f6-h49jx
```

Once you get into Mongo Shell, you will see the following:

```plain
rsName:PRIMARY>
```

Congratulations! You have just formed your own MongoDB ReplicaSet, any data written onto the Primary instance will now be replicated onto secondary instances. If the primary instance were to stop, one of the secondary instances will take over the primary instance's role.

You can view the replica configuration in the Mongo Shell by:

```bash
rsName:PRIMARY> rs.config()
```

****

## Using MongoDB ReplicaSet

Now that you've started MongoDB, you may connect your clients to it with Mongo Connect String URI.

The installation is using NodePort services on the ports 32001, 32002 and 32003:
```bash
 mongo mongodb://mongo-cms-fcmki4ox2hnr-node-0.cern.ch:32001,mongo-cms-fcmki4ox2hnr-node-0.cern.ch:32002,mongo-cms-fcmki4ox2hnr-node-0.cern.ch:32003/admin?replicaSet=rs0 -u clusterAdmin
```


## Debuging

In case you have created a cluster with monitoring enabled you need to delete some of the default monitoring resources so that helm can install and manage them:

```
kubectl delete ClusterRole prometheus-adapter-server-resources
kubectl delete ClusterRole prometheus-adapter-resource-reader
kubectl delete ClusterRoleBinding prometheus-adapter:system:auth-delegator
kubectl delete ClusterRoleBinding prometheus-adapter-resource-reader
kubectl delete ClusterRoleBinding prometheus-adapter-hpa-controlle
kubectl delete APIService v1beta1.custom.metrics.k8s.io
```