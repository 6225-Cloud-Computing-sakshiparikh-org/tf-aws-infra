output "vpc_ids" {
  value = aws_vpc.main[*].id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}

output "alb_dns_name" {
  value = aws_lb.app_lb.dns_name
}

output "asg_name" {
  value = aws_autoscaling_group.app_asg.name
}
