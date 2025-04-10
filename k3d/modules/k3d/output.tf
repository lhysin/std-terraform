output "kube_api_host" {
  value = "https://127.0.0.1:${var.cluster_port}"
  description = "Kubernetes API server URL"
}

output "cluster_ca_certificate" {
  value = base64decode(data.external.kube_config.result["certificate_authority_data"])
  description = "Decoded Kubernetes certificate authority data"
}

output "client_certificate" {
  value = base64decode(data.external.kube_config.result["client_certificate_data"])
  description = "Decoded Kubernetes client certificate data"
}

output "client_key" {
  value = base64decode(data.external.kube_config.result["client_key_data"])
  description = "Decoded Kubernetes client key data"
}