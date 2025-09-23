####################################################
# Route53 alias record pointing to ALB
####################################################

# A record for root or subdomain
resource "aws_route53_record" "alb_alias_a" {
  zone_id = var.hosted_zone_id
  name    = var.domain_name         # example: "app.example.com" or "example.com"
  type    = "A"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}

# Optional AAAA record (IPv6) — enable only if needed
resource "aws_route53_record" "alb_alias_aaaa" {
  count   = var.create_ipv6 ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_lb.app.dns_name
    zone_id                = aws_lb.app.zone_id
    evaluate_target_health = true
  }
}
