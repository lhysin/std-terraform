# ACM 인증서 검색
data "aws_acm_certificate" "acm_certificate" {
  domain     = "*.cjenm-study.com"
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${module.vars.service_name_prefix}-service-alb"
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection = false

  load_balancer_type = "application"

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "10.0.0.0/16"
    }
  }

#   access_logs = {
#     bucket = "my-alb-logs"
#   }

#   listeners = {
#     ex-http-https-redirect = {
#       port     = 80
#       protocol = "HTTP"
#       redirect = {
#         port        = "443"
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#     ex-https = {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn = data.aws_acm_certificate.acm_certificate.arn
#
#       forward = {
#         target_group_key = "ex-instance"
#       }
#     }
#   }
#
#   target_groups = {
#     ex-instance = {
#       name_prefix      = "h1"
#       protocol         = "HTTP"
#       port             = 80
#       target_type      = "instance"
#     }
#   }

#   target_groups = {
#     ex_instance = {
#       name_prefix      = "h1"
#       protocol         = "HTTP"
#       port             = 80
#       target_type      = "instance"
#       health_check     = {
#         path = "/"
#         port = "traffic-port"
#       }
#     }
#  }

  tags = module.vars.service_tags
}