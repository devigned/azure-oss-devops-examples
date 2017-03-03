#!/usr/bin/env bash

project_id="habitat-k8s001"
vm_name="habitat-dev"
cluster_name="k8s-cluster"
location='westus'

# Create the resource group if it doesn't exist
echo "Creating resource group ${project_id} in ${location}"
az group create -n ${project_id} -l ${location} 1>/dev/null

echo "Creating a Chef Habitat development machine (Ubuntu 16.04 LTS) with Azure CLI and Docker also installed"
az vm create -g ${project_id} -n ${vm_name} --admin-username deploy \
    --image Canonical:UbuntuServer:16.04-LTS:latest --custom-data hab_cloud_config.yml --no-wait 1>/dev/null

echo ""
echo "Creating Azure Kubernetes cluster named ${cluster_name} in group ${project_id}"
az acs create -g ${project_id} -n ${cluster_name} --orchestrator-type Kubernetes 1>/dev/null

# Get public IP address for the VM
ip_address=$(az vm list-ip-addresses -g ${project_id} -n ${vm_name} \
    --query "[0].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)

echo "Syncing your local ~/.azure directory to ${vm_name}"
scp -r ~/.azure deploy@${ip_address}:. 1>/dev/null

echo "You can now connect via 'ssh deploy@${ip_address}'"
echo "To delete all of the infrastructure run `az group delete -n ${project_id} -y --no-wait`"
