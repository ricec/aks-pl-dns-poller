output "fqdn" {
  value = data.external.record.result["fqdn"]
}

output "zone" {
  value = null_resource.record_parts.triggers["zone"]
}

output "short_name" {
  value = null_resource.record_parts.triggers["short_name"]
}

output "ipv4_address" {
  value = data.external.record.result["ipv4Address"]
}
