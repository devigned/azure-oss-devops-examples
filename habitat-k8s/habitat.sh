#!/usr/bin/env bash

project_id="habitat-k8s001"
cluster_name="k8s-cluster"

# Read in the public key
if [[ ! -f ~/.ssh/id_rsa ]]; then
    echo "Generating a SSH key pair in ~/.ssh/id_rsa"
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
fi

if [[ ! -f ~/.kube/config ]]; then
    echo "Fetching credentials (kubectl config file) for ${cluster_name} and storing it in ~/.kube/config"
    az acs kubernetes get-credentials -g ${project_id} -n ${cluster_name} 1>/dev/null
fi