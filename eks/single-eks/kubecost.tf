# resource "helm_release" "kubecost" {
#   name = "kubecost"
#   #namespace  = "kubecost"  # 원하는 네임스페이스로 수정
#   chart = "kubecost/cost-analyzer"
#   version = "2.3.3"  # Helm 차트 버전
#   repository = "oci://public.ecr.aws/kubecost"
#
#   #create_namespace = true  # 네임스페이스가 없으면 생성
#
#   values = [
#     <<-EOT
#     persistentVolume:
#       storageClass: gp3
#       defaultStorageClass: gp3
#     prometheus:
#       server:
#         persistentVolume:
#           storageClass: gp3
#     EOT
#   ]
#
#   depends_on = [
#     module.eks
#   ]
# }

# helm install kubecost kubecost/cost-analyzer --version 2.3.3 \
# --set persistentVolume.storageClass=gp3 \
#--set prometheus.server.persistentVolume.storageClass=gp3