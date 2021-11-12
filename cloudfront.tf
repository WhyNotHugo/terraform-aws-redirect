data "aws_cloudfront_cache_policy" "caching_optimised" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_function" "redirect" {
  name    = "redirect-${replace(var.from, ".", "__")}"
  runtime = "cloudfront-js-1.0"
  publish = true
  code = templatefile("${path.module}/function.js", {
    new_domain = var.to
  })
}

resource "aws_cloudfront_distribution" "redirect" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Redirect ${var.from}"

  aliases = [var.from]

  # This is not actually used, but MUST be defined:
  origin {
    domain_name = var.from
    origin_id   = var.from

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimised.id
    compress                   = true
    target_origin_id           = var.from
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
    acm_certificate_arn      = module.certs.acm_certificate_arn
  }
}
