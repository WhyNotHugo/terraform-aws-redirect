module "certs" {
  source = "terraform-aws-modules/acm/aws"

  domain_name         = var.from
  zone_id             = var.zone_id
  wait_for_validation = true
}
