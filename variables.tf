variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the first VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks for the first VPC"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks for the first VPC"
  type        = list(string)
}

variable "second_vpc_cidr" {
  description = "CIDR block for the second VPC"
  type        = string
}

variable "second_public_subnets" {
  description = "List of public subnet CIDR blocks for the second VPC"
  type        = list(string)
}

variable "second_private_subnets" {
  description = "List of private subnet CIDR blocks for the second VPC"
  type        = list(string)
}

variable "network_name" {
  description = "Unique name for this network deployment"
  type        = string
}

variable "vpc_count" {
  description = "Number of VPCs to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ports" {
  description = "List of ports to allow inbound traffic"
  type        = list(number)
  default     = [22, 80, 443]
}

variable "app_port" {
  description = "Port on which the application runs"
  type        = number
}

variable "root_volume_size" {
  description = "Size of the root volume"
  type        = number
  default     = 25
}

variable "root_volume_type" {
  description = "Type of the root volume"
  type        = string
  default     = "gp2"
}

variable "delete_on_termination" {
  description = "Flag to delete EBS volume on instance termination"
  type        = bool
  default     = true
}

variable "protect_against_termination" {
  description = "Flag to prevent accidental termination"
  type        = bool
  default     = false
}
variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for EC2 instances"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "csye6225"
}
