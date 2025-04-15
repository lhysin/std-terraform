locals {
  ecs_frontweb_service_name   = "${var.phase}-${var.project}-ecs-svc-frontweb"
  ecs_frontweb_container_name = "${var.phase}-${var.project}-ecs-task-frontweb"
  ecs_frontweb_container_port = 7570

  ecs_api_service_name   = "${var.phase}-${var.project}-ecs-svc-apiserver"
  ecs_api_container_name = "${var.phase}-${var.project}-ecs-task-apiserver"
  ecs_api_container_port = 7580

  service_discovery_name = "${var.phase}-${var.project}-svc-dscv"
}

resource "aws_service_discovery_http_namespace" "this" {
  name        = local.service_discovery_name
  description = "aws service discovery http namespace namespace for ${local.service_discovery_name}"
  tags        = local.tags
}

# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/service?tab=inputs
module "ecs_frontweb_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = local.ecs_frontweb_service_name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 512
  memory = 1024

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  runtime_platform = {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  # https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/container-definition?tab=inputs
  container_definitions = {


    (local.ecs_frontweb_container_name) = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = local.ecr_frontweb_repo_url
      port_mappings = [
        {
          name          = local.ecs_frontweb_container_name
          containerPort = local.ecs_frontweb_container_port
          hostPort      = local.ecs_frontweb_container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem  = false
      enable_cloudwatch_logging = true
      cloudwatch_log_group_name = "/aws/ecs/${local.ecs_frontweb_service_name}"
      # The soft limit (in MiB) of memory
      memory_reservation        = 256
    }
  }

  load_balancer = {
    service = {
      target_group_arn = module.alb.target_groups[local.frontweb_target_group_name].arn
      container_name   = local.ecs_frontweb_container_name
      container_port   = local.ecs_frontweb_container_port
    }
  }

  subnet_ids = var.private_subnets
  security_group_rules = {
    ingress_alb = {
      type                     = "ingress"
      from_port                = local.ecs_frontweb_container_port
      to_port                  = local.ecs_frontweb_container_port
      protocol                 = "tcp"
      description              = "Allow traffic from ALB to frontweb ECS service"
      source_security_group_id = module.alb.security_group_id
    }
    egress_all = {
      type      = "egress"
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  security_group_tags = local.tags
  security_group_name = "${var.phase}-${var.project}-ecs-svc-sg-frontweb"
  security_group_description = "Security group for ${var.phase}-${var.project} ECS Frontweb Service"

  tags = local.tags
}

module "ecs_api_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  name        = local.ecs_api_service_name
  cluster_arn = module.ecs_cluster.arn

  cpu    = 512
  memory = 1024

  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  runtime_platform = {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  # Container definition(s)
  container_definitions = {

    (local.ecs_api_container_name) = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = local.ecr_apiserver_repo_url
      port_mappings = [
        {
          name          = local.ecs_api_container_name
          containerPort = local.ecs_api_container_port
          hostPort      = local.ecs_api_container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      cloudwatch_log_group_name = "/aws/ecs/${local.ecs_api_container_name}"
      # The soft limit (in MiB) of memory
      memory_reservation = 256
    }
  }

  # http://apiserver.${local.service_discovery_name}:7580
  service_connect_configuration = {
    namespace = aws_service_discovery_http_namespace.this.arn
    service = {
      port_name      = local.ecs_api_container_name
      discovery_name = "apiserver"
      client_alias = {
        port     = local.ecs_api_container_port
        dns_name = "apiserver"
      }
    }
  }

  subnet_ids = var.private_subnets
  security_group_rules = {
    ingress_frontweb = {
      type                     = "ingress"
      from_port                = local.ecs_api_container_port
      to_port                  = local.ecs_api_container_port
      protocol                 = "tcp"
      description              = "Allow communication from frontweb ECS to apiserver"
      source_security_group_id = module.ecs_frontweb_service.security_group_id
    }
    egress_all = {
      type      = "egress"
      from_port = 0
      to_port   = 0
      protocol  = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  security_group_tags = local.tags
  security_group_name = "${var.phase}-${var.project}-ecs-svc-sg-apiserver"
  security_group_description = "Security group for ${var.phase}-${var.project} ECS Apiverser Service"

  tags = local.tags
}