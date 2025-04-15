# Security Group for ALB - allow HTTP from anywhere (0.0.0.0/0)
resource "aws_security_group" "alb" {
  name        = "${var.service_name}-alb-sg-${var.environment}"
  description = "Security group for ALB allowing HTTP ingress"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.service_name}-alb-sg-${var.environment}"
  }
}

# Security Group for ECS Tasks - allow port 5000 only from ALB
resource "aws_security_group" "ecs_task" {
  name        = "${var.service_name}-task-sg-${var.environment}"
  description = "Security group for ECS tasks (Flask container)"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 5000
    to_port         = 5000
    security_groups = [aws_security_group.alb.id]  # only ALB SG can access
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.service_name}-task-sg-${var.environment}"
  }
}
