locals {
  ontrust_ingress_name = "ontrust-ingress"
  ontrust_ingress_namespace = "ontrust"
  ontrust_ingress_group_name = "ontrust-grp"

  ontrust_host = "eks-test-ontrust.${var.route53_domain_name}"
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
#       "alb.ingress.kubernetes.io/load-balancer-arn" = local.service_alb_arn
#       "alb.ingress.kubernetes.io/target-group-arn"  = aws_lb_target_group.ontrust_tg.arn

      //"alb.ingress.kubernetes.io/backend-protocol-version" = "GRPC"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}, {\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/subnets" = join(",", local.public_subnets)

#       "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
#       "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
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
              # 최초 진입 서비스는 bff-api
              name = "bff-api"
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
    module.mgmt_eks_blueprints_addons,
    kubernetes_namespace.ontrust_namespace
  ]
}

data "aws_lb" "eks_alb_ontrust" {
  count = var.enable_ontrust_ingress ? 1 : 0
  tags = {
    "ingress.k8s.aws/stack" = local.ontrust_ingress_group_name
  }
  depends_on = [
    kubernetes_ingress_v1.ontrust_ingress,
    //kubernetes_ingress_v1.guestbook_ingress
  ]
}

resource "aws_route53_record" "ontrust_cname" {
  count = var.enable_ontrust_ingress ? 1 : 0
  zone_id = data.aws_route53_zone.target_hosted_zone.zone_id
  name    = local.ontrust_host
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_lb.eks_alb_ontrust[count.index].dns_name]
  depends_on = [
    data.aws_lb.eks_alb_ontrust
  ]
}