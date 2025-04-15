locals {
  cluster_name = "${var.phase}-${var.project}-ecs"
}

# https://registry.terraform.io/modules/terraform-aws-modules/ecs/aws/latest/submodules/cluster?tab=inputs
module "ecs_cluster" {
  source = "terraform-aws-modules/ecs/aws//modules/cluster"

  cluster_name = local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/${local.cluster_name}"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.tags
}