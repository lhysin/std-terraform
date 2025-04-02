resource "kubernetes_namespace" "k9s_ns_phase_fargate" {
  metadata {
    name = "${var.phase}-fargate"
  }
}

resource "helm_release" "echo_server" {
  name       = "echo-server"
  repository = "https://ealenn.github.io/charts"
  chart      = "echo-server"
  version    = "0.5.0"
  namespace  = kubernetes_namespace.k9s_ns_phase_fargate.metadata[0].name
  create_namespace = true

  depends_on = [
    kubernetes_namespace.k9s_ns_phase_fargate,
    helm_release.ingress_nginx
  ]
}

# resource "helm_release" "http_webhook" {
#   name       = "http-webhook"
#   repository = "oci://ghcr.io/securecodebox/helm"
#   chart      = "http-webhook"
#   version    = "4.13.0"
#   namespace = var.phase
#   create_namespace = true
# }