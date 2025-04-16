# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.service_name}-cluster-${var.environment}"
}

# IAM role for ECS task execution (pulling images, logging)
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.service_name}-ecs-exec-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Log Group for the application logs
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.service_name}-${var.environment}"
  retention_in_days = 7
}

# ECR Repository for Docker image
resource "aws_ecr_repository" "app" {
  name                 = "${var.service_name}"
  image_tag_mutability = "MUTABLE"
}

# ECS Task Definition for the Flask app
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.service_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  # No task_role_arn needed since the container doesn't call AWS APIs

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:${var.container_image_tag}"
      essential = true
      portMappings = [{
        containerPort = 5000
        hostPort      = 5000
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# ECS Service to run the task behind the ALB
resource "aws_ecs_service" "app" {
  name            = "${var.service_name}-svc-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]
}
