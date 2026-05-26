output "load_balancer_dns_name" {
  value = module.platform.load_balancer_dns_name
}

output "backend_repository_url" {
  value = module.platform.backend_repository_url
}

output "frontend_repository_url" {
  value = module.platform.frontend_repository_url
}

output "asset_bucket_name" {
  value = module.platform.asset_bucket_name
}
