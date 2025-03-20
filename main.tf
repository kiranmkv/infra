provider "aws" {
  region = var.aws_region
}

# EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids = var.subnet_ids
  }
}

resource "aws_iam_role" "fargate_profile_role" {
  name = "eks-fargate-profile-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks-fargate-pods.amazonaws.com" }
    }]
  })
}

resource "aws_eks_fargate_profile" "fargate" {
  cluster_name           = aws_eks_cluster.eks.name
  fargate_profile_name   = "default"
  pod_execution_role_arn = aws_iam_role.fargate_profile_role.arn
  subnet_ids             = var.subnet_ids
  selector {
    namespace = "default"
  }
}

# Security Group for EKS
resource "aws_security_group" "eks_sg" {
  name   = "eks-security-group"
  vpc_id = var.vpc_id
}

# Amazon ECR
resource "aws_ecr_repository" "frontend_repo" {
  name = "frontend"
}

resource "aws_ecr_repository" "backend_repo" {
  name = "backend"
}

# Route 53 Domain
resource "aws_route53_zone" "primary" {
  name = "kiran-devops.com"
}

# Amazon EC2 with Session Manager enabled
resource "aws_iam_role" "ec2_role" {
  name = "ec2-session-manager-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[0]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.eks_sg.id]
  tags = {
    Name = "ec2-instance"
  }
}
