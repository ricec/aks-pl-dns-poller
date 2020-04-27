locals {
  cluster_id = {
    aks_cluster_name           = var.aks_cluster_name
    aks_cluster_resource_group = var.aks_cluster_resource_group
  }
}

resource "null_resource" "poll" {
  triggers = local.cluster_id

  provisioner "local-exec" {
    command     = "${path.module}/scripts/poll_for_private_endpoint.sh"
    environment = local.cluster_id
  }
}

data "external" "record" {
  program = [
    "${path.module}/scripts/get_api_server_private_endpoint.sh",
    null_resource.poll.triggers["aks_cluster_name"],
    null_resource.poll.triggers["aks_cluster_resource_group"]
  ]
}

resource "null_resource" "record_parts" {
  triggers = (length(data.external.record.result["fqdn"]) == 0 ? 
    { zone = "", short_name = "" } :
    regex("(?P<short_name>.*)\\.(?P<zone>privatelink\\..*\\.azmk8s\\.io)", data.external.record.result["fqdn"]))
}
