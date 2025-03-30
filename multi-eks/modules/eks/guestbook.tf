terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.18.0"
    }
  }
}

locals {

  service_alb_arn = data.terraform_remote_state.shared.outputs.service_alb_arn

  guestbook_ingress_name = "guestbook-ingress"
  guestbook_ingress_namespace = "guestbook"

  guestbook_host = "eks-test-guestbook.${var.route53_domain_name}"
}

resource "kubernetes_namespace" "guestbook_namespace" {
  metadata {
    name = local.guestbook_ingress_namespace
  }
}

resource "kubectl_manifest" "guestbook_application" {
  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: "https://github.com/argoproj/argocd-example-apps.git"
    path: guestbook
    targetRevision: main
  destination:
    server: "https://kubernetes.default.svc"
    namespace: "${local.guestbook_ingress_namespace}"
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
YAML

  depends_on = [
    module.mgmt_eks_blueprints_addons,
    kubernetes_namespace.guestbook_namespace
  ]
}


resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = local.service_alb_arn
  port              = 80
  protocol          = "HTTP"

  # default_action {
  #   type = "fixed-response"
  #   fixed_response {
  #     content_type = "text/plain"
  #     message_body = "Service not found"
  #     status_code  = "404"
  #   }
  # }

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.guestbook_tg.arn  # 타겟 그룹 ARN
  }
}

resource "aws_lb_target_group" "guestbook_tg" {
  name        = "${var.service_name_prefix}-guestbook-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }
}

resource "kubernetes_ingress_v1" "guestbook_ingress" {
  metadata {
    name      = local.guestbook_ingress_name
    namespace = local.guestbook_ingress_namespace
    annotations = {
      # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.3/guide/ingress/annotations/
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" = "ip"
      "alb.ingress.kubernetes.io/load-balancer-arn" = local.service_alb_arn
      "alb.ingress.kubernetes.io/target-group-arn"  = aws_lb_target_group.guestbook_tg.arn

      //"alb.ingress.kubernetes.io/backend-protocol-version" = "GRPC"

      "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\": 443}, {\"HTTP\": 80}]"
      "alb.ingress.kubernetes.io/subnets" = join(",", local.public_subnets)

      # "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
      # "alb.ingress.kubernetes.io/backend-protocol" = "HTTPS"
    }

  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = local.guestbook_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "guestbook"
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
    kubernetes_namespace.guestbook_namespace
  ]
}