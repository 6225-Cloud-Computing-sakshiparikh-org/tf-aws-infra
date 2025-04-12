# Generate a random password for RDS
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store the password in Secrets Manager
resource "random_id" "secret_suffix" {
  byte_length = 4
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.network_name}-db-password-${random_id.secret_suffix.hex}"
  description             = "RDS database password"
  recovery_window_in_days = 7
  kms_key_id              = aws_kms_key.secrets_key.arn

  tags = {
    Name = "${var.network_name}-db-password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    dbname   = var.db_name
    engine   = "mysql"
    port     = 3306
    host     = aws_db_instance.rds_instance.address
  })

  depends_on = [aws_db_instance.rds_instance]
}
