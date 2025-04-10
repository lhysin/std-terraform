locals {
  argo_cd_ingress_name = "argocd-ingress"
  argo_cd_ingress_namespace = "argocd"

  # eks-pri-argocd.cjenm-study.com
  argo_cd_host = "eks-${var.eks_suffix_name}-argocd.${var.route53_domain_name}"
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  count = var.enable_argocd ? 1 : 0
  metadata {
    name      = local.argo_cd_ingress_name
    namespace = local.argo_cd_ingress_namespace
    annotations = {
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}, {\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/subnets" = join(",", var.public_subnets)
      "alb.ingress.kubernetes.io/security-groups" = var.alb_cjenm_only_ingress_sg_id
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.seoul_wildcard_cert.arn
      "external-dns.alpha.kubernetes.io/hostname" = local.argo_cd_host

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
    module.eks_blueprints_addons,
  ]
}