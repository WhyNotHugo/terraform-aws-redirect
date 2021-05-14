# terraform-aws-redirect
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FWhyNotHugo%2Fterraform-aws-redirect.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FWhyNotHugo%2Fterraform-aws-redirect?ref=badge_shield)


Sets up redirections using AWS CloudFront and Lambda@Edge.

Redirects bare domains to www domains, e.g.:

    example.com -> www.example.com

It also makes sure HSTS is on (non-trivial when using CloudFront or similar
balancers).

Can also set up alias domains, e.g.:

    www.example.com.ar -> www.example.ar
    www.olddomain.com -> www.newdomain.com

Again, HSTS headers are set. Redirections are set in a way that they comply
with the requirements for HSTS preloading (e.g.: redirecting HTTP to HTTPS in
the right order).

## Terraform versions

Originally written on Terraform 0.14. Currently used with Terraform 0.15.

## Usage

Full example:

```hcl
module "redirect" {
  source = "terraform-awsredirect"

  domains       = ["example.com", "anotherexample.com"]
  alias_domains = {"example.com.ar": "example.ar"}
}
```

No aliases:
```hcl
module "redirect" {
  source = "terraform-awsredirect"

  domains       = ["example.com", "anotherexample.com"]
}
```

## Providers

This module will use its own provider set to `us-east-1`, since CloudFront and
related resources MUST exist in that region.

## Licence

Copyright (c) 2021, Hugo Osvaldo Barrera <hugo@barrera.io>  
This project is licensed under the ISC licence. See LICENCE for details.


[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FWhyNotHugo%2Fterraform-aws-redirect.svg?type=large)](https://app.fossa.com/projects/git%2Bgithub.com%2FWhyNotHugo%2Fterraform-aws-redirect?ref=badge_large)