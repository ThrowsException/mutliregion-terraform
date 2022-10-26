data "aws_region" "current" {}

resource "aws_ecs_cluster" "this" {
  name = "multi-region"
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  task_role_arn            = "arn:aws:iam::063754174791:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::063754174791:role/ecsTaskExecutionRole"
  container_definitions = jsonencode([
    {
      "environment" : [
        { "name" : "REGION", "value" : "${data.aws_region.current.name}" }
      ],
      "essential" : true,
      "image" : "${var.image}",
      "name" : "app",
      "portMappings" : [
        {
          "containerPort" : 3000
        }
      ]
      "linuxParameters" : {
        "initProcessEnabled" : true
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name = "multi-region"

  task_definition = aws_ecs_task_definition.this.arn
  cluster         = aws_ecs_cluster.this.id
  network_configuration {
    assign_public_ip = true
    subnets          = var.subnets
    security_groups  = var.security_groups
  }
  desired_count = 0

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 3000
  }
}

resource "aws_lb" "this" {
  name               = "multi-region"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "app" {
  name        = "app"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc

}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
