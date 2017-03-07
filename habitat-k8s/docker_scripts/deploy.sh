#!/usr/bin/env bash

project_id="habitat-k8s"
vm_name="habitat-dev"
cluster_name="k8s-cluster"
location='westus'

if [[ -z $(az account list -o tsv 2>/dev/null ) ]]; then
    az login 1>/dev/null
fi

if [[ ! -f ~/.ssh/kube_rsa ]]; then
    echo "Generating ssh keys to use for setting up the Kubernetes cluster"
    ssh-keygen -f ~/.ssh/kube_rsa -t rsa -N '' 1>/dev/null
else
    echo "Using ~/.ssh/kube_rsa"
fi

if [[ -z $(az acs show -g habitat-k8s001 -n k8s-cluster) ]]; then
    echo "Creating Resource group named ${project_id}"
    az group create -n ${project_id} -l ${location} 1>/dev/null

    echo "Creating Azure Kubernetes cluster named ${cluster_name} in group ${project_id}"
    az acs create -g ${project_id} -n ${cluster_name} --orchestrator-type Kubernetes \
        --ssh-key-value ~/.ssh/kube_rsa.pub --agent-vm-size Standard_DS2_v2 1>/dev/null
else
    echo "Using Azure Kubernetes cluster named ${cluster_name} in group ${project_id}"
fi

if [[ ! -f /usr/local/bin/kubectl ]]; then
    echo "Installing kubectl in /usr/local/bin/kubectl"
    sudo az acs kubernetes install-cli 1>/dev/null
else
    echo "Using kubectl in /usr/local/bin/kubectl"
fi

if [[ ! -d ${HOME}.kube/config ]]; then
    echo "Creating ${HOME}.kube/config w/ credentials for managing ${cluster_name}"
    az acs kubernetes get-credentials --ssh-key-file ~/.ssh/kube_rsa 1>/dev/null
else
    echo "Using ${HOME}.kube/config w/ credentials for managing ${cluster_name}"
fi

echo ""
echo "Your Kubernetes cluster has been deployed and you are ready to connect."
echo "To connect to the cluster run 'kubectl cluster-info'"
