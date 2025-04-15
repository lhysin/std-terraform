data "aws_acm_certificate" "seoul_wildcard_cert" {
  domain = "*.${var.domain}"
}

locals {

  frontweb_target_group_name = "${var.phase}-${var.project}-tg-frontweb"
  frontweb_host              = "${var.phase}-frontweb.cjenm.media"

  jenkins_target_group_name = "${var.phase}-${var.project}-tg-jekins"
  jenkins_ec2_id            = "i-063a26301587937fc"
  jenkins_host              = "build-jenkins.cjenm.media"
}

# https://registry.terraform.io/modules/terraform-aws-modules/alb/aws/latest?tab=inputs
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
  security_group_tags = local.tags
  security_group_name = "${var.phase}-${var.project}-alb-sg"
  security_group_description = "Security group for ${var.phase}-${var.project} ALB"

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
        frontweb-host-forward = {
          priority = 1000

          conditions = [
            {
              host_header = {
                values = [local.frontweb_host]
              }
            }
          ]

          actions = [
            {
              type             = "forward"
              target_group_key = local.frontweb_target_group_name
            }
          ]
        }

        jenkins-host-forward = {
          priority = 40000

          conditions = [
            {
              host_header = {
                values = [local.jenkins_host]
              }
            }
          ]

          actions = [
            {
              type             = "forward"
              target_group_key = local.jenkins_target_group_name
            }
          ]
        }
      }

      forward = {
        target_group_key = local.frontweb_target_group_name
      }
    }
  }

  target_groups = {
    (local.frontweb_target_group_name) = {
      name             = local.frontweb_target_group_name
      backend_protocol = "HTTP"
      backend_port     = local.ecs_frontweb_container_port
      target_type      = "ip"
      deregistration_delay = 300
      #load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200,302"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 5
      }

      # There's nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    },

    (local.jenkins_target_group_name) = {
      name = local.jenkins_target_group_name

      name        = local.jenkins_target_group_name
      protocol    = "HTTP"
      port        = 8080
      target_type = "instance"
      target_id   = local.jenkins_ec2_id

      health_check = {
        enabled             = "true"
        healthy_threshold   = "2"
        interval            = "30"
        matcher             = "200,403"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
        unhealthy_threshold = "5"
      }
    }
  }

  tags = local.tags
}