data "aws_acm_certificate" "seoul_wildcard_cert" {
  domain = "*.${var.domain}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name = "${var.phase}-${var.project}-alb"

  load_balancer_type = "application"

  vpc_id = var.vpc_id
  subnets = var.public_subnets

  # For example only
  enable_deletion_protection = false

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  listeners = {
    ex-http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    ex-https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = data.aws_acm_certificate.seoul_wildcard_cert.arn


      rules = {
        ex-weighted-forward = {
          priority = 1000
          actions = [{
            type = "weighted-forward"
            target_groups = [
              {
                target_group_key = local.ecs_frontweb_service_name
                weight           = 1
              }
            ]
            stickiness = {
              enabled  = true
              duration = 3600
            }
          }]

          conditions = [{
            query_string = {
              key   = "weighted"
              value = "true"
            }
          }]
        }
      }
      forward = {
        target_group_key = local.ecs_frontweb_service_name
      }
    }
  }

  target_groups = {
    (local.ecs_frontweb_service_name) = {
      name                              = "${var.phase}-${var.project}-tg-frontweb"
      backend_protocol                  = "HTTP"
      backend_port                      = local.ecs_frontweb_container_port
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/login"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }

  tags = local.tags
}