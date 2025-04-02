module "mgmt_eks" {
  source              = "./modules/eks"
  region              = var.region
  profile             = var.profile
  service_name_prefix = local.service_name_prefix
  vpc_id              = module.vpc.vpc_id
  enable_argocd       = true
  public_subnets      = module.vpc.public_subnets_by_az["a"]
  private_subnets     = module.vpc.private_subnets_by_az["a"]
  intra_subnets       = module.vpc.intra_subnets_by_az["a"]
  tags                = local.cj_enm_tags
  depends_on = [module.vpc, module.sg]
}


locals {
  argo_cd_ingress_name      = "argocd-ingress"
  argo_cd_ingress_namespace = "argocd"
  grafana_ingress_name      = "grafana-ingress"
  grafana_ingress_namespace = "kube-prometheus-stack"
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = local.argo_cd_ingress_name
    namespace = local.argo_cd_ingress_namespace
    annotations = {
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"

      //"alb.ingress.kubernetes.io/backend-protocol-version" = "GRPC"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}, {\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/subnets" = join(",", var.public_subnets)
      //"alb.ingress.kubernetes.io/security-groups" = module.alb_ingress_sg.security_group_id

      "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
      "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"

      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"

      //"external-dns.alpha.kubernetes.io/hostname" = "eks-test-argocd.${var.route53_domain_name}"

    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = var.argo_cd_hostname

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

  depends_on = [module.mgmt_eks_blueprints_addons]
}