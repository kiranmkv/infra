output "eks_cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "ecr_frontend_repo_url" {
  value = aws_ecr_repository.frontend_repo.repository_url
}

output "ecr_backend_repo_url" {
  value = aws_ecr_repository.backend_repo.repository_url
}

output "route53_zone_id" {
  value = aws_route53_zone.primary.zone_id
}

output "ec2_instance_id" {
  value = aws_instance.ec2.id
}
