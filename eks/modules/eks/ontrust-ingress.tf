locals {
  ontrust_ingress_name = "ontrust-ingress"
  ontrust_ingress_namespace = "ontrust"
  ontrust_ingress_group_name = "ontrust-grp"

  # eks-ontrust.cjenm-study.com
  ontrust_host = "eks-ontrust.${var.route53_domain_name}"
}

resource "kubernetes_namespace" "ontrust_namespace" {
  count = var.enable_ontrust_ingress ? 1 : 0
  metadata {
    name = local.ontrust_ingress_namespace
  }
}

resource "kubernetes_ingress_v1" "ontrust_ingress" {
  count = var.enable_ontrust_ingress ? 1 : 0
  metadata {
    name      = local.ontrust_ingress_name
    namespace = local.ontrust_ingress_namespace
    annotations = {
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/group.name" = local.ontrust_ingress_group_name
      "alb.ingress.kubernetes.io/group.order" = "1"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/management/path/health"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}, {\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/subnets" = join(",", var.public_subnets)

      "alb.ingress.kubernetes.io/security-groups" = var.alb_ingress_sg_id
      "alb.ingress.kubernetes.io/certificate-arn" = data.aws_acm_certificate.seoul_wildcard_cert.arn

      "external-dns.alpha.kubernetes.io/hostname" = local.ontrust_host
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = local.ontrust_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
#               # 최초 진입 서비스는 bff-api
#               name = "bff-api"
              # 최초 진입 서비스는 api-gateway
              name = "api-gateway"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    module.eks_blueprints_addons,
    kubernetes_namespace.ontrust_namespace
  ]
}