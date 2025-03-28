resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.46.3"
  values = [
    <<EOF
    autoDiscovery:
      clusterName: ${data.aws_eks_cluster.eks.name}
    awsRegion: ${var.region}
    EOF
  ]
}