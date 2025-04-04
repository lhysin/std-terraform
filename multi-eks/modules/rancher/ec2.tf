resource "aws_instance" "ec2_rancher" {
  ami           = "ami-070e986143a3041b6"  # 사용하고자 하는 AMI ID (여기서는 Amazon Linux 2 AMI)
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

              # Rancher 컨테이너 실행
              sudo docker run -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher:v2.11.0

              # Rancher 부트스트랩 비밀번호 확인 (로그)
              sudo docker logs $(sudo docker ps -q --filter ancestor=rancher/rancher) 2>&1 | grep "Bootstrap Password:"
              EOF

  # cat /var/log/cloud-init.log

  subnet_id              = var.public_subnets[0]
  security_groups        = [var.ssh_sg_id, var.alb_ingress_sg_id]
  associate_public_ip_address = true

  tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-ec2-rancher"
  })

  lifecycle {
    ignore_changes = [
      security_groups
    ]
  }
}