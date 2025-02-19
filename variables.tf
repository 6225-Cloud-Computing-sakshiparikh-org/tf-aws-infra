variable "aws_region" {}
variable "aws_profile" {}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "availability_zones" {
  type = list(string)
}
