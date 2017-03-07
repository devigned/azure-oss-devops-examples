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
- **Run container:** `$ docker run -it --name az-hab-k8s devigned/az-hab-k8s`
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
