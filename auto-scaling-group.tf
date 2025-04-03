resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "${var.network_name}-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg[0].id]
  }

  user_data = base64encode(<<-EOF
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
  )

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      delete_on_termination = var.delete_on_termination
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-instance"
    }
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.network_name}-asg"
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  vpc_zone_identifier       = [for subnet in aws_subnet.public : subnet.id]
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "webapp-instance"
    propagate_at_launch = true
  }

  depends_on = [aws_db_instance.rds_instance]
}

# Scale up policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.network_name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# Scale down policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.network_name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

# CloudWatch alarm for high CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.network_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  alarm_description   = "Scale up when CPU > 5%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}

# CloudWatch alarm for low CPU
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.network_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 3
  alarm_description   = "Scale down when CPU < 3%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}
