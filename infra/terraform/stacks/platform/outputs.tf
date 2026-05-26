output "load_balancer_dns_name" {
  value = module.container_platform.load_balancer_dns_name
}

output "backend_repository_url" {
  value = module.container_platform.backend_repository_url
}

output "frontend_repository_url" {
  value = module.container_platform.frontend_repository_url
}

output "asset_bucket_name" {
  value = module.data.asset_bucket_name
}
