resource "aws_instance" "app_instance" {
  count                  = var.vpc_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.app_sg[count.index].id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.key_name

  # Explicit dependency for RDS
  depends_on = [aws_db_instance.rds_instance]

  user_data = <<-EOF
            #!/bin/bash
            # Create directory if it doesn't exist
            mkdir -p /opt/csye6225
            # Set permissions
            chown -R csye6225:csye6225 /opt/csye6225
            # Write environment variables
            cat > /opt/csye6225/.env <<EOL
            DB_HOST=${aws_db_instance.rds_instance.address}
            DB_USER=${var.db_username}
            DB_PASSWORD=${var.db_password}
            DB_NAME=${var.db_name}
            PORT=${var.app_port}
            AWS_REGION=${var.aws_region}
            AWS_S3_BUCKET_NAME=${aws_s3_bucket.private_bucket.bucket}
            EOL
            chmod 600 /opt/csye6225/.env
            # Ensure service starts
            systemctl daemon-reload
            systemctl restart webapp
            EOF

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.delete_on_termination
  }

  tags = {
    Name = "${var.network_name}-App-Instance-${count.index + 1}"
  }
}
