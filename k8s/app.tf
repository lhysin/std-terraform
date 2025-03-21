resource "helm_release" "echo_server" {
  name       = "echo-server"
  repository = "https://ealenn.github.io/charts"
  chart      = "echo-server"
  version    = "0.5.0"
  namespace  = var.phase
  create_namespace = true
}

# resource "helm_release" "http_webhook" {
#   name       = "http-webhook"
#   repository = "oci://ghcr.io/securecodebox/helm"
#   chart      = "http-webhook"
#   version    = "4.13.0"
#   namespace = var.phase
#   create_namespace = true
# }