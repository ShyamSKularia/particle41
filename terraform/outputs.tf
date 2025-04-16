output "alb_dns_name" {
  description = "DNS name of the application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the app Docker image"
  value       = aws_ecr_repository.app.repository_url
}
