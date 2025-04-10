# Spring Cloud Data Flow

resource "helm_release" "spring_cloud_dataflow" {
  name       = "scdf"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "spring-cloud-dataflow"
  version    = "35.0.2"

  values = [
    <<-EOT
    metrics:
      enabled: true
    EOT
  ]
}