resource "aws_lb" "app_lb" {
  name               = "${var.network_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg[0].id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = false

  tags = {
    Name = "${var.network_name}-ALB"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.network_name}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main[0].id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "${var.network_name}-TG"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
