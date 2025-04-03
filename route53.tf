# Get the hosted zone for your subdomain (dev or demo)
data "aws_route53_zone" "selected" {
  name         = "${var.aws_profile}.${var.domain_name}"
  private_zone = false
}

# Create a record pointing to the load balancer
resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.aws_profile}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}
