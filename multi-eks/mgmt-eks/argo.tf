locals {
  argo_cd_ingress_name = "argocd-ingress"
  argo_cd_ingress_namespace = "argocd"
  ingress_group_name = "cjo-eks-ing-grp"

  argo_cd_host = "eks-test-argocd.${var.route53_domain_name}"

  alb_cjenm_only_ingress_sg_id = data.terraform_remote_state.shared.outputs.alb_cjenm_only_ingress_sg_id
}

module "mgmt_eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.20.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  enable_argocd = true
  enable_aws_efs_csi_driver = true

  depends_on = [
    module.eks
  ]
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = local.argo_cd_ingress_name
    namespace = local.argo_cd_ingress_namespace
    annotations = {
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
       "alb.ingress.kubernetes.io/group.name" = local.ingress_group_name
       "alb.ingress.kubernetes.io/group.order" = "2"
      //"alb.ingress.kubernetes.io/backend-protocol-version" = "GRPC"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}, {\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/subnets" = join(",", local.public_subnets)
      "alb.ingress.kubernetes.io/security-groups" = local.alb_cjenm_only_ingress_sg_id

      "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"

      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = local.argo_cd_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argo-cd-argocd-server"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    module.mgmt_eks_blueprints_addons,
    //kubectl_manifest.guestbook_application
  ]
}


# kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
# 최초 로그인 이후 xharhdiddl!@# (톰고양이123)으로 변경
data "aws_lb" "eks_alb_argo_cd" {
  tags = {
    "ingress.k8s.aws/stack" = local.ingress_group_name
  }
  depends_on = [
    kubernetes_ingress_v1.argocd_ingress,
    //kubernetes_ingress_v1.guestbook_ingress
  ]
}

resource "aws_route53_record" "argo_cd_cname" {
  zone_id = data.aws_route53_zone.target_hosted_zone.zone_id
  name    = local.argo_cd_host
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_lb.eks_alb_argo_cd.dns_name]
  depends_on = [
    data.aws_lb.eks_alb_argo_cd
  ]
}


# # argocd 네임스페이스에 admin 권한을 부여하는 Role 정의
# resource "kubernetes_role" "argocd_admin" {
#   metadata {
#     name      = "argocd-admin-role"
#     namespace = "argocd"
#   }
#
#   rule {
#     api_groups = [""]
#     resources  = ["pods", "services", "configmaps", "secrets", "deployments"]
#     verbs      = ["get", "list", "create", "update", "delete"]
#   }
#
#   rule {
#     api_groups = ["apps"]
#     resources  = ["deployments", "statefulsets", "replicasets"]
#     verbs      = ["get", "list", "create", "update", "delete"]
#   }
# }
#
# # admin 계정에 Role을 바인딩하는 RoleBinding 정의
# resource "kubernetes_role_binding" "argocd_admin_binding" {
#   metadata {
#     name      = "argocd-admin-binding"
#     namespace = "argocd"
#   }
#
#   subject {
#     kind      = "User"
#     name      = "admin"  # 관리자 계정 이름
#     api_group = "rbac.authorization.k8s.io"
#   }
#
#   role_ref {
#     kind     = "Role"
#     name     = kubernetes_role.argocd_admin.metadata[0].name
#     api_group = "rbac.authorization.k8s.io"
#   }
# }