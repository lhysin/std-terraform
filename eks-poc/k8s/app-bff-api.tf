# ECR 리포지토리 URL
data "aws_ecr_repository" "bff_api" {
  name = "cjo-std-ecr-bff-api"
}

resource "kubernetes_config_map" "bff_api_config" {
  metadata {
    name      = "bff-api-config"
    namespace  = kubernetes_namespace.k9s_ns_phase_fargate.metadata[0].name
  }

  data = {
    SPRING_APPLICATION_JSON = jsonencode({
      bff = {
        httpclient = {
          clients = {
            "echo-server" = {
              base_url        = "http://echo-server.${var.phase}.svc.cluster.local"
              connect_timeout = "2s"
            }
          }
        }
        routes = [
          {
            id = "echo-server"
            predicates = [
              {
                name = "pathPredicate"
                # /api/echo-server/**
                args = "/**"
              }
            ]
            route_pattern = {
              type = "ROUTE"
              process = {
                target_id = "echo-server"
              }
            }
          }
        ]
      }
    })
  }

  depends_on = [kubernetes_namespace.k9s_ns_phase_fargate]
}


resource "kubernetes_deployment" "bff_api_deployment" {
  metadata {
    name      = "bff-api-deployment"
    namespace  = kubernetes_namespace.k9s_ns_phase_fargate.metadata[0].name
  }

  spec {
    replicas = 1  # 복제본 수
    selector {
      match_labels = {
        app = "bff-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "bff-api"
        }
      }

      spec {
        container {
          name  = "bff-api"
          image = "${data.aws_ecr_repository.bff_api.repository_url}:latest"  # ECR에서 최신 태그의 이미지를 사용

          port {
            container_port = 8080
          }

          env {
            name = "SPRING_APPLICATION_JSON"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.bff_api_config.metadata[0].name
                key  = "SPRING_APPLICATION_JSON"
              }
            }
          }
          #           env {
          #             name  = "JAVA_OPTS"
          #             value = "--logging.level.root=DEBUG"
          #           }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.k9s_ns_phase_fargate]
}


resource "kubernetes_service" "bff_api_service" {
  metadata {
    name      = "bff-api-service"
    namespace  = kubernetes_namespace.k9s_ns_phase_fargate.metadata[0].name
  }

  spec {
    selector = {
      app = "bff-api"
    }

    port {
      port = 80       # 외부에서 접근할 포트
      target_port = 8080     # 컨테이너 내부 포트
    }

    type = "ClusterIP"
  }

  depends_on = [
    kubernetes_namespace.k9s_ns_phase_fargate,
    helm_release.ingress_nginx
  ]
}