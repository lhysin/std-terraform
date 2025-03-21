resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  create_namespace = true
  chart      = "argo-cd"
  version    = "7.8.13"
  repository = "https://argoproj.github.io/argo-helm"

  values = [
    <<EOF
  controller:
    replicaCount: 2
    service:
      type: ClusterIP
  server:
    extraArgs:
      - --insecure  # HTTPS 리디렉션 방지
    ingress:
      enabled: true
      ingressClassName: nginx
      annotations:
        nginx.ingress.kubernetes.io/ssl-redirect: "false"
        nginx.ingress.kubernetes.io/force-ssl-redirect: "false"
      hosts:
        - "eks-test-argocd.${var.route53_domain_name}"
      tls: []
  EOF
  ]
}

# kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
# 최초 로그인 이후 xharhdiddl!@# (톰고양이123)으로 변경

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "false"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"
    }
  }

  spec {
    ingress_class_name = "nginx"  # Nginx Ingress Controller 사용

    rule {
      host = "eks-test-argocd.${var.route53_domain_name}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}