variable "aws_region" {
  description = "AWS region to deploy the resources in"
  type        = string
  default     = "us-east-1"
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}
variable "service_name" {
  description = "Name of the service (used for naming resources)"
  type        = string
  default     = "simple-time-service"
}
variable "environment" {
  description = "Deployment environment (e.g., dev, prod) for resource naming"
  type        = string
  default     = "dev"
}
variable "desired_count" {
  description = "Number of ECS task instances to run"
  type        = number
  default     = 1
}
variable "container_image_tag" {
  description = "Docker image tag to deploy from ECR"
  type        = string
  default     = "latest"
}
