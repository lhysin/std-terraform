resource "aws_security_group" "eks_control_plane_sg" {
  name        = "${local.service_prefix}-ctrl-plane-sg-${local.service_name}"
  description = "EKS Control Plane Security Group"
  vpc_id      =  aws_vpc.main.id


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # API 서버 접근을 위한 CIDR 범위
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 모든 outbound 트래픽 허용
  }
}

resource "aws_security_group" "eks_worker_nodes_sg" {
  name        = "${local.service_prefix}-wrk-nodes-sg-${local.service_name}"
  description = "EKS Worker Nodes Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # kubelet API 접근을 위한 포트
  }

  ingress {
    from_port   = 10255
    to_port     = 10255
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # read-only Kubelet API 포트
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block] # NodePort 서비스 접근을 위한 포트 범위
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 모든 outbound 트래픽 허용
  }
}

resource "aws_security_group" "eks_node_to_control_plane" {
  name        = "${local.service_prefix}-eks-node-to-ctrl-plane-sg-${local.service_name}"
  description = "Allow worker nodes to communicate with control plane"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.eks_control_plane_sg.id] # EKS API 서버와의 통신 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 모든 outbound 트래픽 허용
  }
}

resource "aws_security_group" "nginx_lb_sg" {
  name        = "${local.service_prefix}-nginx-lb-sg-${local.service_name}"
  description = "Security group for Nginx Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 가능
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 모든 outbound 트래픽 허용
  }
}


resource "aws_security_group" "nginx_lb_sg_8080" {
  name        = "${local.service_prefix}-nginx-8080-lb-sg-${local.service_name}"
  description = "Security group for Nginx Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 모든 IP에서 접근 가능
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # 모든 outbound 트래픽 허용
  }
}
