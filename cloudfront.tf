data "aws_cloudfront_cache_policy" "caching_optimised" {
  # id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_request_policy" "all_requests_equal" {
  name = "AllRequestsEqual"
  cookies_config { cookie_behavior = "none" }
  headers_config { header_behavior = "none" }
  query_strings_config { query_string_behavior = "none" }
}

resource "aws_cloudfront_distribution" "redirect_domains" {
  for_each = var.domains

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Redirect ${each.key}"

  aliases = [each.key]

  # This is not actually used, but MUST be defined:
  origin {
    # Set origin to the actual destination domain.
    # This is because the CloudFront->Lambda request will use this host
    # in the request, and not the one specified by the end client.
    domain_name = each.key
    origin_id   = each.key

    custom_header {
      name  = "X-Redirect-Type"
      value = "redirect"
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimised.id
    compress                 = true
    target_origin_id         = each.key
    viewer_protocol_policy   = "redirect-to-https"
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_requests_equal.id

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.redirect.qualified_arn
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
    acm_certificate_arn      = module.redirect_certs[each.key].this_acm_certificate_arn
  }
}

resource "aws_cloudfront_distribution" "alias_domains" {
  for_each = var.alias_domains

  enabled         = true
  is_ipv6_enabled = true
  comment         = "Alias redirect ${each.key}"

  aliases = ["www.${each.key}"]

  # This is not actually used, but MUST be defined:
  origin {
    # Set origin to the actual destination domain.
    # This is because the CloudFront->Lambda request will use this host
    # in the request, and not the one specified by the end client.
    domain_name = each.key
    origin_id   = each.key

    custom_header {
      name  = "X-Redirect-Type"
      value = "alias"
    }

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_optimised.id
    compress                 = true
    target_origin_id         = each.key
    viewer_protocol_policy   = "redirect-to-https"
    origin_request_policy_id = aws_cloudfront_origin_request_policy.all_requests_equal.id

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.redirect.qualified_arn
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
    acm_certificate_arn      = module.alias_certs[each.key].this_acm_certificate_arn
  }
}
