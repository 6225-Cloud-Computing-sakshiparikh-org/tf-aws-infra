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
            # Database Configuration
            DB_HOST=${aws_db_instance.rds_instance.address}
            DB_USER=${var.db_username}
            DB_PASSWORD=${var.db_password}
            DB_NAME=${var.db_name}

            # Application Configuration
            PORT=${var.app_port}
            NODE_ENV=production

            # AWS Configuration
            AWS_REGION=${var.aws_region}
            AWS_S3_BUCKET_NAME=${aws_s3_bucket.private_bucket.bucket}

            # Logging Configuration
            LOG_LEVEL=info

            # Metrics Configuration
            STATSD_HOST=localhost
            STATSD_PORT=8125
            STATSD_PREFIX=WebApp.
            EOL
            chmod 600 /opt/csye6225/.env

            # Configure CloudWatch Agent
            mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/
            cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOL'
            {
              "agent": {
                "metrics_collection_interval": 10,
                "run_as_user": "root"
              },
              "logs": {
                "logs_collected": {
                  "files": {
                    "collect_list": [
                      {
                        "file_path": "/var/log/webapp.log",
                        "log_group_name": "csye6225-webapp-logs",
                        "log_stream_name": "{instance_id}-application",
                        "retention_in_days": 7
                      }
                    ]
                  }
                }
              },
              "metrics": {
                "namespace": "WebApp",
                "metrics_collected": {
                  "statsd": {
                    "service_address": ":8125",
                    "metrics_collection_interval": 10,
                    "metrics_aggregation_interval": 10
                  }
                },
                "append_dimensions": {
                  "InstanceId": "$${aws:InstanceId}"
                }
              }
            }
            EOL

            # Ensure proper permissions for CloudWatch config
            chmod 644 /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
            sudo chown root:root /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

            # Start/Restart CloudWatch Agent with proper error handling
            echo "Starting CloudWatch Agent..."
            sudo systemctl stop amazon-cloudwatch-agent || true
            sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
            
            # Ensure CloudWatch agent starts on boot
            sudo systemctl enable amazon-cloudwatch-agent
            
            # Ensure webapp service starts
            systemctl daemon-reload
            sudo systemctl restart webapp
            systemctl start webapp
            EOF

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.delete_on_termination
  }

  disable_api_termination = var.protect_against_termination

  tags = {
    Name = "${var.network_name}-EC2-${count.index + 1}"
  }
}
