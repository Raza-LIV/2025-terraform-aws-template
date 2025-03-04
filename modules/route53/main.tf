resource "aws_route53_zone" "core_zone" {
  name = var.domain_name
}

resource "aws_route53_record" "core" {
  zone_id = aws_route53_zone.core_zone.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = var.cf_domain_name
    zone_id                = var.cf_hosted_zone_id
    evaluate_target_health = false
  }
}
