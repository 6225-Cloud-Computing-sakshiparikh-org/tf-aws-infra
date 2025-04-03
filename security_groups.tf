resource "aws_security_group" "app_sg" {
  count       = var.vpc_count
  name        = "${var.network_name}-app-sg-${count.index + 1}"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main[count.index].id

  # Restrict SSH to specific IPs
  ingress {
    description = "SSH from trusted IPs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application port - only allow traffic from the load balancer
  ingress {
    description     = "Application port"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.lb_sg[count.index].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.network_name}-App-SG-${count.index + 1}"
  }
}

resource "aws_security_group" "lb_sg" {
  count       = var.vpc_count
  name        = "${var.network_name}-lb-sg-${count.index + 1}"
  description = "Security group for load balancer"
  vpc_id      = aws_vpc.main[count.index].id

  # Standard web ports
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.network_name}-LB-SG-${count.index + 1}"
  }
}

resource "aws_security_group" "db_sg" {
  count       = var.vpc_count
  name        = "${var.network_name}-db-sg-${count.index + 1}"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main[count.index].id

  ingress {
    description     = "MySQL from App Servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg[count.index].id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.network_name}-DB-SG-${count.index + 1}"
  }
}
