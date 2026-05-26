output "database_endpoint" {
  value = aws_db_instance.postgres.address
}

output "asset_bucket_name" {
  value = aws_s3_bucket.assets.bucket
}
