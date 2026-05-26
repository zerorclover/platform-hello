output "backend_repository_url" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_repository_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "backend_security_group_id" {
  value = aws_security_group.service.id
}

output "load_balancer_dns_name" {
  value = aws_lb.this.dns_name
}
