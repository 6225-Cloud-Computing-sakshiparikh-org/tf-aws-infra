resource "aws_vpc" "main" {
  count      = var.vpc_count
  cidr_block = count.index == 0 ? var.vpc_cidr : var.second_vpc_cidr

  tags = {
    Name = "${var.network_name}-VPC-${count.index + 1}"
  }
}
