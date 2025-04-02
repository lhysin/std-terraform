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

  subnet_id              = var.public_subnets[0]
  security_groups        = [var.ssh_sg_id, var.alb_ingress_sg_id]
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.rancher_instance_profile.name

  tags = merge(var.tags, {
    Name = "${var.service_name_prefix}-ec2-rancher"
  })
}

resource "aws_iam_instance_profile" "rancher_instance_profile" {
  name = "${var.service_name_prefix}-ec2-profile-rancher"
  role = aws_iam_role.rancher_role.name
}

resource "aws_iam_role" "rancher_role" {
  name               = "${var.service_name_prefix}-ec2-role-rancher"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = { Service = "ec2.amazonaws.com" }
        Effect    = "Allow"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_policy" {
  name        = "${var.service_name_prefix}-ec2-policy-rancher"
  description = "Policy for Rancher EC2 to manage EKS clusters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["eks:DescribeCluster", "eks:ListClusters", "eks:ListUpdates"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "iam:ListRoles"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rancher_policy_attachment" {
  policy_arn = aws_iam_policy.eks_policy.arn
  role       = aws_iam_role.rancher_role.name
}