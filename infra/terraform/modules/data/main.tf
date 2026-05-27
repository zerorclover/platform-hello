resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-db"
  description = "PostgreSQL access from backend tasks"
  vpc_id      = var.vpc_id

  ingress {
    description = "PostgreSQL from private application subnets"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-db"
    Component = "database"
  })
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-db"
    Component = "database"
  })
}

resource "random_password" "database" {
  length  = 32
  special = false
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.name_prefix}-postgres"
  engine                  = "postgres"
  engine_version          = var.db_engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.db_allocated_storage
  storage_encrypted       = true
  db_name                 = var.db_name
  username                = var.db_username
  password                = random_password.database.result
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [aws_security_group.database.id]
  backup_retention_period = var.db_backup_retention_days
  skip_final_snapshot     = !var.deletion_protection
  deletion_protection     = var.deletion_protection
  publicly_accessible     = false

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-postgres"
    Component = "database"
  })
}

resource "aws_secretsmanager_secret" "database_url" {
  name        = "${var.name_prefix}/database-url"
  description = "Database connection URL for ${var.name_prefix}"

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-database-url"
    Component = "database"
  })
}

resource "aws_secretsmanager_secret_version" "database_url" {
  secret_id = aws_secretsmanager_secret.database_url.id
  secret_string = format(
    "postgres://%s:%s@%s:5432/%s",
    var.db_username,
    random_password.database.result,
    aws_db_instance.postgres.address,
    var.db_name
  )
}

resource "aws_s3_bucket" "assets" {
  bucket = "${var.name_prefix}-assets"

  tags = merge(var.tags, {
    Name      = "${var.name_prefix}-assets"
    Component = "assets"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket                  = aws_s3_bucket.assets.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
