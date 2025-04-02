# resource "aws_eks_addon" "example" {
#   cluster_name = data.aws_eks_cluster.eks.name
#   addon_name   = "kubecost"
# }