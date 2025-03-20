output "vpc_ids" {
  value = aws_vpc.main[*].id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "ec2_instance_ids" {
  value = aws_instance.app_instance[*].id
}

output "ec2_public_ips" {
  value = aws_instance.app_instance[*].public_ip
}

# outputs.tf
output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}
