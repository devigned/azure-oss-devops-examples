# Run Habitat Apps in Kubernetes on Azure

> Habitat simplifies creating, managing, and running containers. Habitat allows you to 
package applications in a compact, atomic, and easily auditable manner that more fully 
delivers on the promise of containers. Habitat has a number of additional benefits, 
but one of the places it particularly shines is striking the right balance between 
manageability, portability, and consistency in managing a fleet of microservice 
applications. For most users, that means running in tandem with a scheduler and a 
container management platform. Today we’re going to explore how to run Habitat 
applications in Kubernetes.

via https://blog.chef.io/2016/11/08/how-to-run-habitat-applications-in-kubernetes/

## Prerequisites
To use this demo, you will need to have [Docker](https://docs.docker.com/engine/installation/) installed.

## Overview of Components

### Habitat / K8s development container
The habitat development VM provides all of the tools needed to build and deploy a k8s cluster and
Habitat packages on Azure. The machine comes provisioned with Azure CLI, Habitat CLI, Docker, 
kubectl, git and a scripts to help you get started.

### Azure K8s Cluster
The Azure Kubernetes Cluster is a fully functional Azure Container Service running the
Kubernetes orchestrator. All nodes are running on Standard_DS2_v2 (2 CPU cores, 7 GiB RAM, 14 GiB local SSD). 
Standard_DS2_v2 can use Premium Storage, which provides high-performance, low-latency storage for I/O intensive 
workloads. These VMs use solid-state drives (SSDs) to host a virtual machine’s disks and also provide a local 
SSD disk cache.
- 3 Master nodes
- 2 Agent nodes

## Running the Demo

### Setup a Habitat development container and a K8s cluster
- **Run container:** 

  ```
  $ docker run -v /var/run/docker.sock:/var/run/docker.sock \
      -it --privileged --name az-hab-k8s devigned/az-hab-k8s
  ```
- **Deploy K8s Cluster:** `$ ./deploy` *(inside the `az-hab-k8s` container)*
  - The [deploy script](./docker_scripts/deploy.sh) will deploy the k8s cluster and create the `~/kube/.config`
  
Output from the script should be the following:
```
demo@f0fded5bb9af:~$ ./deploy.sh
To sign in, use a web browser to open the page https://aka.ms/devicelogin and enter the code XXXXXXXX to authenticate.
CloudName    IsDefault    Name                              State    TenantId
-----------  -----------  --------------------------------  -------  ------------------------------------
AzureCloud   True         xxxxxxxxx                         Enabled  XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX

Generating ssh keys to use for setting up the Kubernetes cluster
Enter file in which to save the key (/home/demo/.ssh/id_rsa):
Creating Resource group named habitat-k8s
Creating Azure Kubernetes cluster named k8s-cluster in group habitat-k8s
Creating /home/demo.kube/config w/ credentials for managing k8s-cluster
Your Kubernetes cluster has been deployed and you are ready to connect
To connect to the cluster run 'kubectl cluster-info'

demo@f0fded5bb9af:~$ kubectl cluster-info
Kubernetes master is running at https://k8s-cluster-habitat-k8s-xxxxx.westus.cloudapp.azure.com
Heapster is running at https://k8s-cluster-habitat-k8s-xxxxx.westus.cloudapp.azure.com/api/v1/proxy/namespaces/kube-system/services/heapster
KubeDNS is running at https://k8s-cluster-habitat-k8s-xxxxx.westus.cloudapp.azure.com/api/v1/proxy/namespaces/kube-system/services/kube-dns
kubernetes-dashboard is running at https://k8s-cluster-habitat-k8s-xxxxx.westus.cloudapp.azure.com/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard
```

### Reattach to the development container
If you exit from the container, you can restart / attach to the container again with the following steps.
- **Start container:** `$ docker start az-hab-k8s`
- **Attach to container:** `$ docker attach az-hab-k8s`

### Deploying your first Habitat Package
- `$ git clone https://github.com/habitat-sh/core-plans.git`
- `$ hab origin key generate az-hab-k8s`
- `$ hab studio -k az-hab-k8s -s core-plans/redis enter`
- `[1][default:/src:0]# ls`

    ```
      README.md  config  default.toml  plan.sh
    ```
- `[2][default:/src:0]# vi plan.sh`
  - change pkg_origin from `core` to `az-hab-k8s`
- `[3][default:/src:0]# vi default.toml`
  - change `protected-mode="yes"` to `protected-mode="no"`
- `[4][default:/src:0]# build`

    ```
       redis: hab-plan-build cleanup
       redis:
       redis: Source Cache: /hab/cache/src/redis-3.2.4
       redis: Installed Path: /hab/pkgs/az-hab-k8s/redis/3.2.4/20170307213311
       redis: Artifact: /src/results/az-hab-k8s-redis-3.2.4-20170307213311-x86_64-linux.hart
       redis: Build Report: /src/results/last_build.env
       redis: SHA256 Checksum: f9ccd359d01ca163327092e83c774a27fb6feb4b778e81bf9af9f09b19b3f678
       redis: Blake2b Checksum: 07b86b36626e83ed73c7b57d32be83d42179a105d7a9ca311a0f71e7141c0615  /hab/cache/artifacts/az-hab-k8s-redis-3.2.4-20170307213311-x86_64-linux.hart
       redis:
       redis: I love it when a plan.sh comes together.
       redis:
       redis: Build time: 1m36s
    ```
- `[5][default:/src:0]# ls -l results/`

    ```
      -rw-r--r-- 1 root root 582479 Mar  7 21:34 az-hab-k8s-redis-3.2.4-20170307213311-x86_64-linux.hart
      -rw-r--r-- 1 root root    436 Mar  7 21:34 last_build.env
    ```
- `[6][default:/src:0]# hab pkg export docker az-hab-k8s/redis`
- `[7][default:/src:0]# hab pkg install core/docker`
- `[8][default:/src:0]# hab pkg exec core/docker docker tag az-hab-k8s/redis k8sregistry-on.azurecr.io/az-hab-k8s/redis`
- `$ sudo docker push k8sregistry-on.azurecr.io/az-hab-k8s/redis:latest`
- `$ kubectl run redis --image=gcr.io/$PROJECT_ID/redis:latest --port=6379`
- `$ kubectl get pods`

    ```
     NAME                     READY     STATUS    RESTARTS   AGE
     redis-1425394292-9jlql   1/1       Running   0          25s
    ```
- `$ kubectl logs redis-1425394292-9jlql`

    ```
      hab-sup(MR): Butterfly Member ID 3a1c8c1fe6a5402c8f4afdad52b83a10
      hab-sup(SR): Adding az-hab-k8s/redis/3.2.4/20170307220342
      hab-sup(MR): Starting butterfly on 0.0.0.0:9638
      hab-sup(MR): Starting http-gateway on 0.0.0.0:9631
      hab-sup(SC): Updated redis.config e7c6f76ce2c2707b075f335de82d15dda1e07f8870eb220e492313bf8f1074b8
      redis.default(SR): Initializing
      redis.default(SV): Starting process as user=hab, group=hab
      redis.default(O):                 _._
      redis.default(O):            _.-``__ ''-._
      redis.default(O):       _.-``    `.  `_.  ''-._           Redis 3.2.4 (00000000/0) 64 bit
      redis.default(O):   .-`` .-```.  ```\/    _.,_ ''-._
      redis.default(O):  (    '      ,       .-`  | `,    )     Running in standalone mode
      redis.default(O):  |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
      redis.default(O):  |    `-._   `._    /     _.-'    |     PID: 32
      redis.default(O):   `-._    `-._  `-./  _.-'    _.-'
      redis.default(O):  |`-._`-._    `-.__.-'    _.-'_.-'|
      redis.default(O):  |    `-._`-._        _.-'_.-'    |           http://redis.io
      redis.default(O):   `-._    `-._`-.__.-'_.-'    _.-'
      redis.default(O):  |`-._`-._    `-.__.-'    _.-'_.-'|
      redis.default(O):  |    `-._`-._        _.-'_.-'    |
      redis.default(O):   `-._    `-._`-.__.-'_.-'    _.-'
      redis.default(O):       `-._    `-.__.-'    _.-'
      redis.default(O):           `-._        _.-'
      redis.default(O):               `-.__.-'
      redis.default(O):
    ```
