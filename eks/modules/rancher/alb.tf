data "aws_acm_certificate" "seoul_wildcard_cert" {
  domain = "*.${var.route53_domain_name}"
}

resource "aws_lb" "alb_rancher" {
  name               = "${var.service_name_prefix}-alb-rancher"
  internal           = false
  load_balancer_type = "application"
  # eks 보안그룹 필요
  #security_groups   = [var.alb_cjenm_only_ingress_sg_id]  # 필요에 따라 보안 그룹을 지정하세요.
  subnets           = [var.public_subnets[0], var.public_subnets[1]]
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  tags = var.tags
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb_rancher.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"  # SSL 정책 설정
  certificate_arn   = data.aws_acm_certificate.seoul_wildcard_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_rancher.arn  # 타겟 그룹 ARN
  }
}

resource "aws_alb_target_group_attachment" "alb_target_group_att_rancher" {
  target_group_arn = aws_lb_target_group.alb_tg_rancher.arn
  target_id        = aws_instance.ec2_rancher.id
}

resource "aws_lb_target_group" "alb_tg_rancher" {
  name        = "${var.service_name_prefix}-alb-tg-rancher"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/healthz"              # Rancher 헬스체크 경로
    interval            = 30                       # 헬스체크 간격
    timeout             = 3                        # 헬스체크 타임아웃
    healthy_threshold   = 3                        # 건강한 상태로 간주되는 연속 헬스체크 횟수
    unhealthy_threshold = 3                        # 비정상 상태로 간주되는 연속 실패 횟수
    matcher             = "200-299"                # 헬스체크가 성공으로 간주할 HTTP 상태 코드 범위
  }
}

# 이미 등록된 호스팅 존 정보 가져오기
data "aws_route53_zone" "target_hosted_zone" {
  name = "${var.route53_domain_name}." # 대상 도메인 (마침표로 끝나는 FQDN 형식)
}

resource "aws_route53_record" "alb_record" {
  zone_id = data.aws_route53_zone.target_hosted_zone.id
  name    = "eks-test-rancher.${var.route53_domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.alb_rancher.dns_name
    zone_id                = aws_lb.alb_rancher.zone_id
    evaluate_target_health = true
  }
}