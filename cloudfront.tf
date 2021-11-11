data "aws_cloudfront_cache_policy" "caching_optimised" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "Managed-SecurityHeadersPolicy"
}

resource "aws_cloudfront_function" "redirect" {
  for_each = var.domains

  name    = "redirect-${replace(each.key, ".", "__")}"
  runtime = "cloudfront-js-1.0"
  publish = true
  code = templatefile("${path.module}/function.js", {
    new_domain = "www.${each.value}"
  })
}

resource "aws_cloudfront_distribution" "redirect_domains" {
  for_each = var.domains

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Redirect ${each.key}"

  aliases = [each.key]

  # This is not actually used, but MUST be defined:
  origin {
    domain_name = each.key
    origin_id   = each.key

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
    target_origin_id           = each.key
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.redirect[each.key].arn
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
    acm_certificate_arn      = module.redirect_certs[each.key].acm_certificate_arn
  }
}

resource "aws_cloudfront_function" "alias" {
  for_each = var.alias_domains

  name    = "alias-${replace(each.key, ".", "__")}"
  runtime = "cloudfront-js-1.0"
  publish = true
  code = templatefile("${path.module}/function.js", {
    new_domain = each.value
  })
}

resource "aws_cloudfront_distribution" "alias_domains" {
  for_each = var.alias_domains

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Alias redirect ${each.key}"

  aliases = ["www.${each.key}"]

  # This is not actually used, but MUST be defined:
  origin {
    domain_name = each.key
    origin_id   = each.key

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
    target_origin_id           = each.key
    viewer_protocol_policy     = "redirect-to-https"
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security_headers.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.alias[each.key].arn
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
    acm_certificate_arn      = module.alias_certs[each.key].acm_certificate_arn
  }
}
