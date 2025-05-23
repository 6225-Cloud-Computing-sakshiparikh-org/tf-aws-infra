# For dev environment - request certificate from ACM
resource "aws_acm_certificate" "cert" {
  count             = var.aws_profile == "dev" ? 1 : 0
  domain_name       = "${var.aws_profile}.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Name = "${var.network_name}-certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS records for certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in var.aws_profile == "dev" ? aws_acm_certificate.cert[0].domain_validation_options : [] : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.zone_id
}

# Validate the certificate
resource "aws_acm_certificate_validation" "cert" {
  count                   = var.aws_profile == "dev" ? 1 : 0
  certificate_arn         = aws_acm_certificate.cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
