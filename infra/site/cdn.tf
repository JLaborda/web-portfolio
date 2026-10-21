resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "web-portfolio-${var.environment}"
  description                       = "Origin access control for the ${var.environment} site bucket."
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "site" {
  name        = "web-portfolio-${var.environment}"
  comment     = "Honor origin Cache-Control within 0 seconds and 365 days."
  min_ttl     = 0
  default_ttl = 3600
  max_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }

    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

resource "aws_cloudfront_response_headers_policy" "noindex" {
  count   = var.environment == "staging" ? 1 : 0
  name    = "web-portfolio-staging-noindex"
  comment = "Tell crawlers not to index staging."

  custom_headers_config {
    items {
      header   = "X-Robots-Tag"
      override = true
      value    = "noindex"
    }
  }
}

resource "aws_cloudfront_function" "rewrite" {
  name    = "web-portfolio-${var.environment}-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite directory URLs to Hugo index.html objects."
  publish = true
  code    = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;
      if (uri === "/") {
        request.uri = "/index.html";
        return request;
      }
      if (uri.charAt(uri.length - 1) === "/") {
        request.uri = uri + "index.html";
        return request;
      }
      var slash = uri.lastIndexOf("/");
      var last = uri.substring(slash + 1);
      if (last.indexOf(".") === -1) {
        request.uri = uri + "/index.html";
      }
      return request;
    }
  EOT
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  comment             = "web-portfolio ${var.environment}"
  price_class         = "PriceClass_100"
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "site"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "site"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = aws_cloudfront_cache_policy.site.id
    # Null on production, so that distribution does not send X-Robots-Tag.
    response_headers_policy_id = one(aws_cloudfront_response_headers_policy.noindex[*].id)

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.rewrite.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Looks up the deploy role by name. This stack does not read infra/shared state.
data "aws_iam_role" "deploy" {
  name = "web-portfolio-${var.environment}-deploy"
}

data "aws_iam_policy_document" "invalidate" {
  statement {
    sid       = "InvalidateOwnDistribution"
    effect    = "Allow"
    actions   = ["cloudfront:CreateInvalidation"]
    resources = [aws_cloudfront_distribution.site.arn]
  }
}

resource "aws_iam_role_policy" "invalidate" {
  name   = "cloudfront-create-invalidation"
  role   = data.aws_iam_role.deploy.name
  policy = data.aws_iam_policy_document.invalidate.json
}
