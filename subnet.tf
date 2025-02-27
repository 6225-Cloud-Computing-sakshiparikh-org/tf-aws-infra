resource "aws_subnet" "public" {
  count = var.vpc_count * length(var.public_subnets)

  vpc_id                  = aws_vpc.main[floor(count.index / length(var.public_subnets))].id
  cidr_block              = count.index < length(var.public_subnets) ? var.public_subnets[count.index % length(var.public_subnets)] : var.second_public_subnets[count.index % length(var.second_public_subnets)]
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))

  tags = {
    Name = "${var.network_name}-Public-Subnet-${floor(count.index / length(var.public_subnets)) + 1}-${count.index % length(var.public_subnets) + 1}"
  }
}

resource "aws_subnet" "private" {
  count = var.vpc_count * length(var.private_subnets)

  vpc_id            = aws_vpc.main[floor(count.index / length(var.private_subnets))].id
  cidr_block        = count.index < length(var.private_subnets) ? var.private_subnets[count.index % length(var.private_subnets)] : var.second_private_subnets[count.index % length(var.second_private_subnets)]
  availability_zone = element(data.aws_availability_zones.available.names, count.index % length(data.aws_availability_zones.available.names))

  tags = {
    Name = "${var.network_name}-Private-Subnet-${floor(count.index / length(var.private_subnets)) + 1}-${count.index % length(var.private_subnets) + 1}"
  }
}
