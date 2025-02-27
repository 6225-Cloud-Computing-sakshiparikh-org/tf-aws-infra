data "aws_ami" "webapp_ami" {
  most_recent = true
  owners      = ["self"] // This ensures we only look for AMIs owned by your account

  filter {
    name   = "name"
    values = ["webapp-ami-*"] // Match the naming pattern from your Packer build
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_instance" "app_instance" {
  count         = var.vpc_count
  ami           = data.aws_ami.webapp_ami.id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Explicitly request a public IP
  associate_public_ip_address = true

  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.app_sg[count.index].id]

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = var.delete_on_termination
  }

  disable_api_termination = var.protect_against_termination

  tags = {
    Name = "${var.network_name}-App-Instance-${count.index + 1}"
  }
}
