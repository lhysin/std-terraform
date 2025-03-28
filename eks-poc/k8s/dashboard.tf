resource "helm_release" "kubernetes_dashboard" {
  name              = "kubernetes-dashboard"
  namespace         = "kubernetes-dashboard"
  create_namespace  = true
  chart             = "kubernetes-dashboard"
  version           = "7.11.1"
  repository        = "https://kubernetes.github.io/dashboard"

  values = [
    <<EOF
    kong:
      proxy:
        http:
          enabled: true
    EOF
  ]

  set {
    name  = "kong.admin.tls.enabled"
    value = "false"
  }
}

resource "kubernetes_ingress_v1" "dashboard_ingress" {
  metadata {
    name      = "kubernetes-dashboard-ingress"
    namespace = "kubernetes-dashboard"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      #"nginx.ingress.kubernetes.io/ssl-passthrough": "true"
      #"nginx.ingress.kubernetes.io/ssl-redirect": "true"
    }
  }

  spec {
    ingress_class_name = "nginx"  # Nginx Ingress Controller 사용

    rule {
      host = "eks-test-dashboard.${var.route53_domain_name}"

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = "kubernetes-dashboard-kong-proxy"
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

resource "kubernetes_service_account" "dashboard" {
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
  }
}

resource "kubernetes_cluster_role_binding" "dashboard-admin" {
  metadata {
    name = "kubernetes-dashboard-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard.metadata[0].name
    namespace = kubernetes_service_account.dashboard.metadata[0].name
  }

  role_ref {
    kind     = "ClusterRole"
    name     = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
}

# kubectl -n kubernetes-dashboard create token kubernetes-dashboard

# kubectl proxy
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/kubernetes-dashboard-web:8000/proxy/