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
To use this demo, you will need to have installed Azure CLI. Simply run `curl -L https://aka.ms/InstallAzureCli | bash` to install.

## Setup a Habitat development VM and a Kubernetes cluster
- run `./deploy.sh`

### Habitat Development VM
The habitat development VM provides all of the tools needed to build and deploy Habitat
packages on Azure. The machine comes provisioned with Azure CLI pre-authenticated with your
user credentials, Habitat CLI, Docker, kubectl (also pre-authenticated) and git.

### Azure Kubernetes Cluster
The Azure Kubernetes Cluster is a fully functional Azure Container Service running the
Kubernetes orchestrator.

## Running the Demo on the Habitat Development VM
