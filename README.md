# SimpleTimeService

A simple Python web service that returns the current time and client IP address, packaged as a Docker container and deployable on AWS (ECS Fargate with an Application Load Balancer) using Terraform.

## Features

- **Python Microservice:** Uses Flask to serve a single endpoint (`/`) that returns JSON containing the current timestamp and the requester's IP.
- **Dockerized Application:** Lightweight Docker image based on Python 3.11 slim, running as a non-root user for security.
- **Terraform Infrastructure:** Scripts to provision AWS resources: a VPC with public/private subnets, an ECS Fargate cluster and service, an Application Load Balancer, security groups, a NAT gateway for outbound access, and an ECR repository for the Docker image.

## Prerequisites

- **AWS Account:** Access to an AWS account with permissions to create VPCs, ECS clusters, etc.
- **AWS CLI:** Install the AWS Command Line Interface and configure your credentials. Run `aws configure` to set your AWS Access Key, Secret Key, and default region, or ensure `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_DEFAULT_REGION` environment variables are set.
- **Docker:** Install Docker to build and run the container.
- **Terraform:** Install Terraform (v1.0+). 

## Building and Testing Locally

1. **Build the Docker image:**  
   Navigate to the `app/` directory and build the Docker image:
   ```bash
   cd app
   docker build -t simple-time-service:latest .

2. **Run the container locally:** 
    docker run -p 5000:5000 simple-time-service:latest
    curl http://localhost:5000/
    You should see a JSON response, e.g.:
    {"timestamp": "2025-04-15T04:25:33Z", "ip": "127.0.0.1"}

3. **Deployment to AWS (ECS Fargate)**
    Follow these steps to deploy the application to AWS using Terraform. Ensure your AWS credentials are configured (via environment or aws configure) before proceeding.

a>  **Initialize Terraform:**
    cd terraform
    terraform init

b> **Create ECR Repository (Pre-deployment step):**
    terraform apply -target=aws_ecr_repository.app

c> **Build and Push the Docker Image to ECR:**
    aws ecr get-login-password --region <your-aws-region> | \
    docker login --username AWS --password-stdin <account-id>.dkr.ecr.<your-aws-region>.amazonaws.com

    REPO_URL=$(terraform output -raw ecr_repository_url)
    docker tag simple-time-service:latest ${REPO_URL}:latest
    docker push ${REPO_URL}:latest

d> **Deploy the AWS Infrastructure and ECS Service:**
    terraform apply

e> **Test the Deployed Service:**
    export ALB_URL=$(terraform output -raw alb_dns_name)
    curl http://$ALB_URL/


 
