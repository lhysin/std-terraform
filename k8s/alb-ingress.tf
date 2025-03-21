resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = var.phase
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer" # EKS에서는 LoadBalancer 사용 (온프레미스라면 NodePort 가능)
  }

  # https://nangman14.tistory.com/72
  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Cluster"
  }

  set {
    name  = "controller.ingressClass"
    value = "nginx"
  }

  # aws elb
  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }
}

# resource "kubernetes_ingress_v1" "echo_server_ingress" {
#   metadata {
#     name      = "echo-server-ingress"
#     namespace = var.phase
#     annotations = {
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#     }
#   }
#
#   spec {
#     ingress_class_name = "nginx"  # Nginx Ingress Controller 사용
#
#     rule {
#       host = "echo.local"
#
#       http {
#         path {
#           path      = "/"
#           path_type = "Prefix"
#
#           backend {
#             service {
#               name = helm_release.echo_server.name
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }

resource "kubernetes_ingress_v1" "bff_ingress" {
  metadata {
    name      = "bff-ingress"
    namespace = var.phase
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"  # Nginx Ingress Controller 사용

    rule {
      host = "eks-test-bff.${var.route53_domain_name}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.bff_api_service.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

# Nginx Ingress Controller 서비스 정보를 가져옵니다.
data "kubernetes_service" "ingress_nginx_service" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.phase
  }
  depends_on = [
    helm_release.ingress_nginx
  ]
}