#!/bin/bash
set -euo pipefail

# Poll for AKS cluster
while : ; do
  rg="$(az aks show --name "$aks_cluster_name" --resource-group "$aks_cluster_resource_group" --query nodeResourceGroup -o tsv || true)"
  [ -z "$rg" ] || break

  echo 'AKS cluster not found. Sleeping...'
  sleep 10
done

# Poll for Private Endpoint
while : ; do
  pe="$(az network private-endpoint list --resource-group "$rg" --query '[0].id' -o tsv || true)"
  [ -z "$pe" ] || break

  echo 'Private Endpoint not found. Sleeping...'
  sleep 10
done

