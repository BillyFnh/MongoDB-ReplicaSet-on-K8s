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

This Helm Chart is developed on Azure AKS, and uses Azure Managed Disk as Persistent Volume.

If you want to deploy on another cloud provider, you will need to change the storageClass updating `values.yaml` (`./helm-chart/values.yaml`).

****

## Launching MongoDB ReplicaSet

Using Helm, you can launch the application with the this command:

```bash
helm install mongodb ./mongo-replicaset
```

You should see the deploy confirmation message similar to below:

```plain
NAME: mongo
LAST DEPLOYED: Tue Nov 24 17:12:04 **2020**
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
service/mongodb-0-service   ClusterIP   10.0.16.71     <none>        27017/TCP   1s
service/mongodb-1-service   ClusterIP   10.0.77.174    <none>        27017/TCP   1s
service/mongodb-2-service   ClusterIP   10.0.172.241   <none>        27017/TCP   1s

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
service/mongodb-0-service   ClusterIP   10.0.16.71     <none>        27017/TCP   20s
service/mongodb-1-service   ClusterIP   10.0.77.174    <none>        27017/TCP   20s
service/mongodb-2-service   ClusterIP   10.0.172.241   <none>        27017/TCP   20s

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mongodb-0   1/1     1            1           20s
deployment.apps/mongodb-1   1/1     1            1           20s
deployment.apps/mongodb-2   1/1     1            1           20s

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/mongodb-0-9b8c6f869    1         1         1       20s
replicaset.apps/mongodb-1-658f95995d   1         1         1       20s
replicaset.apps/mongodb-2-6cbb444455   1         1         1       20s
```

You can check the MongoDB ReplicaSet status by via Mongo Shell:

```bash
kubectl exec -it -n default <pod-name> mongo
# <pod-name> is the name of pod, for example it could be pod/mongodb-0-7d44df6f6-h49jx
```

Once you get into Mongo Shell, you will see the following:

```plain
rs0:PRIMARY>
```

Congratulations! You have just formed your own MongoDB ReplicaSet, any data written onto the Primary instance will now be replicated onto secondary instances. If the primary instance were to stop, one of the secondary instances will take over the primary instance's role.

You can view the replica configuration in the Mongo Shell by:

```bash
rs0:PRIMARY> rs.config()
```

****

## Using MongoDB ReplicaSet

Now that you've started MongoDB, you may connect your clients to it with Mongo Connect String URI.

If you start another application on the same K8s cluster, you should be able to use DNS name as the URI:

```bash
mongodb://mongodb-0-service:27017,mongodb-1-service:27017,mongodb-2-service:27017
```

<!-- ## Getting Started (the slower way)

Before you can launch a MongoDB ReplicaSet, first you need to obtain the Docker images.

### Pull Docker Image From DockerHub

```bash
docker pull billyfong2007/mongodb-replica-set:latest
```

### Building Docker Image From Source

Go to the root directory of this project, and:

```bash
docker build -t username/mongodb-replica-set .
```

## Launching MongoDB Replica Set

Once you have the required image, -->
