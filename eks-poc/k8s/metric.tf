resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  create_namespace = true
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = "3.12.2"  # 최신 버전 확인 후 설정
  timeout    = 600

  values = [
    <<EOF
    args:
      - --kubelet-insecure-tls
      - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    EOF
  ]
}

# 기본적으로 15초에 한번씪 수집