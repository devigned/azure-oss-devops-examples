#!/usr/bin/env bash

project_id="habitat-k8s"
vm_name="habitat-dev"
cluster_name="k8s-cluster"
location='westus'

if [[ -z $(az account list -o tsv 2>/dev/null ) ]]; then
    az login -o table
fi

if [[ ! -f ~/.ssh/id_rsa ]]; then
    echo "Generating ssh keys to use for setting up the Kubernetes cluster"
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -N '' 1>/dev/null
else
    echo "Using ~/.ssh/id_rsa to authenticate with the Kubernetes cluster"
fi

if [[ -z $(az acs show -g ${project_id} -n ${cluster_name}) ]]; then
    echo "Creating Resource group named ${project_id}"
    az group create -n ${project_id} -l ${location} 1>/dev/null

    echo "Creating Azure Kubernetes cluster named ${cluster_name} in group ${project_id}"
    az acs create -g ${project_id} -n ${cluster_name} --orchestrator-type Kubernetes \
        --agent-vm-size Standard_DS2_v2 --agent-count 2 1>/dev/null
else
    echo "Using Azure Kubernetes cluster named ${cluster_name} in group ${project_id}"
fi

if [[ ! -d ${HOME}.kube/config ]]; then
    echo "Creating ${HOME}.kube/config w/ credentials for managing ${cluster_name}"
    az acs kubernetes get-credentials -g ${project_id} -n ${cluster_name} 1>/dev/null
else
    echo "Using ${HOME}.kube/config w/ credentials for managing ${cluster_name}"
fi

echo ""
echo "Your Kubernetes cluster has been deployed and you are ready to connect."
echo "To connect to the cluster run 'kubectl cluster-info'"
