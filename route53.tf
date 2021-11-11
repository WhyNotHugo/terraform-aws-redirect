data "aws_route53_zone" "domains" {
  for_each = var.domains

  name = each.key
}

data "aws_route53_zone" "alias_domains" {
  for_each = var.alias_domains

  name = each.key
}

resource "aws_route53_record" "redirect_a" {
  for_each = var.domains

  zone_id = data.aws_route53_zone.domains[each.key].id
  name    = each.key
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.redirect_domains[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.redirect_domains[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "redirect_aaaa" {
  for_each = var.domains

  zone_id = data.aws_route53_zone.domains[each.key].id
  name    = each.key
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.redirect_domains[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.redirect_domains[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_a" {
  for_each = var.alias_domains

  zone_id = data.aws_route53_zone.alias_domains[each.key].id
  name    = "www.${each.key}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.alias_domains[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.alias_domains[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "alias_aaaa" {
  for_each = var.alias_domains

  zone_id = data.aws_route53_zone.alias_domains[each.key].id
  name    = "www.${each.key}"
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.alias_domains[each.key].domain_name
    zone_id                = aws_cloudfront_distribution.alias_domains[each.key].hosted_zone_id
    evaluate_target_health = false
  }
}
