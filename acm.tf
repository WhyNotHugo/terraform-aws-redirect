module "redirect_certs" {
  for_each = var.domains

  source = "terraform-aws-modules/acm/aws"

  domain_name         = each.key
  zone_id             = data.aws_route53_zone.domains[each.key].zone_id
  wait_for_validation = true
}

module "alias_certs" {
  for_each = var.domains

  source = "terraform-aws-modules/acm/aws"

  domain_name         = "www.${each.key}"
  zone_id             = data.aws_route53_zone.domains[each.key].zone_id
  wait_for_validation = true
}
