# Spring Cloud Data Flow

# resource "helm_release" "spring_cloud_dataflow" {
#   # scdf-server 이름이 맞지 않으면 인증 이슈 발생
#   name       = "scdf-server"
#   repository = "oci://registry-1.docker.io/bitnamicharts"
#   chart      = "spring-cloud-dataflow"
#   version    = "35.0.2"
#
#   values = [
#     <<-EOT
#     metrics:
#       enabled: true
#     EOT
#   ]
# }