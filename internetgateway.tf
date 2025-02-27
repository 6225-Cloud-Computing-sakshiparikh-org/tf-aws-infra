resource "aws_internet_gateway" "igw" {
  count  = var.vpc_count
  vpc_id = aws_vpc.main[count.index].id

  tags = {
    Name = "${var.network_name}-IGW-${count.index + 1}"
  }
}
