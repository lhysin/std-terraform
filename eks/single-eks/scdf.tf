# Spring Cloud Data Flow

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
  }
  parameters = {
    type   = "gp3"
    fstype = "ext4"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
}

resource "helm_release" "spring_cloud_dataflow" {
  name       = "scdf"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "spring-cloud-dataflow"
  version    = "35.0.2"

  values = [
#     {
#       global = {
#         defaultStorageClass = gp3
#       },
#       metrics = {
#         enabled = true
#       }
#     }
      <<-EOT
      global:
        defaultStorageClass: gp3
      metrics:
        enabled: true
      EOT
  ]

  depends_on = [
    kubernetes_storage_class.gp3
  ]
}