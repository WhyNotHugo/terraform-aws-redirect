# terraform-aws-redirect

Sets up redirections using AWS CloudFront.

    example.com -> www.example.com
    www.olddomain.com -> www.newdomain.com
    www.example.com.ar -> www.example.ar

It also makes sure HSTS is on.

Hint: For HSTS preloading to work, consider always redirecting a bare domain to
`www.`, and avoid redirecting a bare domain _directly_ to another TLD.


## Terraform versions

Originally written on Terraform 0.14. Currently used with Terraform 1.0.10.

## Usage

Full example:

```hcl
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "redirect" {
  source = "terraform-awsredirect"

  from    = "example.com.ar"
  to      = "example.ar"
  zone_id = aws_route53_zone.my_domain.id

  providers = {
    aws = aws.us-east-1
  }
}
```

Redirecting multiple domains:

```
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

module "redirects" {
  for_each = {
    "example.com": "www.example.com.",
    "example.com.ar": "www.example.com.ar",
    "www.example.com.ar: "example.ar",
  }

  source = "WhyNotHugo/redirect/aws"

  from    = "www.${each.key}"
  to      = each.value
  zone_id = aws_route53_zone.my_domains[each.key].zone_id

  providers = {
    aws = aws.us-east-1
  }
}
```

The zone id is required since it's non-trivial to programmatically determine it
for nested domains.

## Providers

This module requires a provider with region set to `us-east-1`, since
CloudFront and related resources MUST exist in that region.

## Licence

Copyright (c) 2021, Hugo Osvaldo Barrera <hugo@barrera.io>  
This project is licensed under the ISC licence. See LICENCE for details.
