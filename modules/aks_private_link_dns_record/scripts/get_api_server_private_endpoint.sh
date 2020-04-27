#!/bin/bash
set -euo pipefail

aks_cluster_name="$1"
aks_cluster_resource_group="$2"

cluster="$(az aks show --name "$aks_cluster_name" --resource-group "$aks_cluster_resource_group" || true)"

if [ -z "$cluster" ]
then
  echo '{ "fqdn": "", "ipv4Address": "" }'
else
  rg="$(jq -r .nodeResourceGroup <<< "$cluster")"
  nic_id="$(az network private-endpoint list --resource-group "$rg" --query '[0].networkInterfaces[0].id' -o tsv)"
  ip="$(az network nic show --ids $nic_id --query 'ipConfigurations[0].privateIpAddress' -o tsv)"

  jq -n \
    --arg fqdn "$(jq -r .privateFqdn <<< "$cluster")" \
    --arg ipv4Address "$ip" \
    '{ "fqdn":$fqdn, "ipv4Address":$ipv4Address }'
fi
