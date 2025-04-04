resource "aws_instance" "ec2_argocd" {
  ami = "ami-070e986143a3041b6"  # 사용하고자 하는 AMI ID (여기서는 Amazon Linux 2 AMI)
  instance_type = "t3.medium"  # EC2 인스턴스 타입

  user_data = <<-EOF
            #!/bin/bash
            set -ex

            # EC2 인스턴스 업데이트
            sudo dnf update -y

            # Docker 설치
            sudo dnf install -y docker

            # Docker 서비스 시작 및 활성화
            sudo systemctl enable --now docker

            # Docker 실행 권한 추가 (ec2-user)
            sudo usermod -aG docker ec2-user

            # Docker가 실행 중인지 확인
            sudo docker info

            curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            kubectl version --client

            # K3d 설치
            curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | sudo bash

            # K3d 클러스터 생성
            k3d cluster create mgmt-argo-cluster --agents 2 --kubeconfig-update-default --port 80:80@loadbalancer:0 --port 443:443@loadbalancer:0

            # K3d 클러스터 확인
            kubectl cluster-info --context mgmt-argo-cluster

            k3d kubeconfig get mgmt-argo-cluster

            mkdir -p ~/.kube
            k3d kubeconfig get mgmt-argo-cluster > ~/.kube/config
            kubectl get svc -A

            # Argo CD 설치
            kubectl create namespace argocd

            # Argo CD 설치 (Helm 사용)
            kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

            # Argo CD 서비스 확인
            kubectl get svc -n argocd

            # Ingress 리소스 생성
            echo "
            apiVersion: networking.k8s.io/v1
            kind: Ingress
            metadata:
              name: argocd-ingress
              namespace: argocd
              annotations:
                ingress.kubernetes.io/ssl-redirect: \"false\"
                ingress.kubernetes.io/secure-backends: \"false\"
            spec:
              rules:
              - http:
                  paths:
                  - path: /
                    pathType: Prefix
                    backend:
                      service:
                        name: argocd-server
                        port:
                          number: 80
            " | kubectl apply -f -

            # Argo CD Web UI 접근하기 위한 로그인
            kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode && echo
  EOF

  # cat /var/log/cloud-init.log

  subnet_id                   = var.public_subnets[0]
  security_groups = [var.ssh_sg_id, var.alb_ingress_sg_id]
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-ec2-argocd"
  })

  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
}