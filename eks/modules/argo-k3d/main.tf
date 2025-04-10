# resource "aws_ecs_cluster" "rancher_cluster" {
#   name = "${var.service_name_prefix}-ecs-cluster-rancher"
#
#   tags = var.tags
# }
#
# resource "aws_ecs_task_definition" "rancher_task" {
#   family             = "${var.service_name_prefix}-ecs-task-rancher"
#   execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
#   network_mode       = "bridge"
#   //requires_compatibilities = ["FARGATE"]
#   cpu                = 1024
#   memory             = 2048
#
#   container_definitions = jsonencode([
#     {
#       name      = "rancher"
#       image     = "rancher/rancher:v2.11.0"
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#           protocol      = "tcp"
#         },
#         {
#           containerPort = 443
#           hostPort      = 443
#           protocol      = "tcp"
#         }
#       ]
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-group         = "/ecs/${var.service_name_prefix}-rancher"
#           awslogs-region        = "ap-northeast-2"
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#       privileged = true
#     }
#   ])
#
#   tags = var.tags
# }
#
# resource "aws_ecs_service" "rancher_service" {
#   name            = "${var.service_name_prefix}-ecs-svc-rancher"
#   cluster         = aws_ecs_cluster.rancher_cluster.id
#   task_definition = aws_ecs_task_definition.rancher_task.arn
#   desired_count   = 1
#   launch_type     = "EC2"
#   //launch_type     = "FARGATE"  # Fargate 사용
#
# #   network_configuration {
# #     subnets          = var.public_subnets
# #     security_groups = [var.alb_cjenm_only_ingress_sg_id]
# #     assign_public_ip = true
# #   }
#
#   load_balancer {
#     target_group_arn = aws_lb_target_group.alb_tg_rancher.arn
#     container_name   = "rancher"
#     container_port   = 80
#   }
#
#   tags = var.tags
# }
#
# resource "aws_iam_role" "ecs_task_execution_role" {
#   name = "${var.service_name_prefix}-ecs-task-exec-role-rancher"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#         Effect = "Allow"
#         Sid    = ""
#       },
#     ]
#   })
# }
#
# resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy_attachment" {
#   role       = aws_iam_role.ecs_task_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }
#
# resource "aws_cloudwatch_log_group" "rancher_log_group" {
#   name              = "/ecs/${var.service_name_prefix}-rancher"
#   retention_in_days = 1
#   tags = var.tags
# }