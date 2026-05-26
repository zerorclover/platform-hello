output "database_endpoint" {
  value = aws_db_instance.postgres.address
}

output "asset_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}

output "database_url_secret_arn" {
  value     = aws_secretsmanager_secret.database_url.arn
  sensitive = true
}
