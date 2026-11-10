# Production custom domain jlaborda.com (spec 006 T001).
# Jorge creates the public hosted zone by hand. Terraform only reads it and
# owns ACM validation CNAMEs plus apex/www alias A/AAAA. No MX or email TXT.

locals {
  is_production = var.environment == "production"
  domain_apex   = "jlaborda.com"
  domain_www    = "www.jlaborda.com"
}

data "aws_route53_zone" "jlaborda" {
  count        = local.is_production ? 1 : 0
  name         = local.domain_apex
  private_zone = false
}

resource "aws_acm_certificate" "jlaborda" {
  count                     = local.is_production ? 1 : 0
  provider                  = aws.us_east_1
  domain_name               = local.domain_apex
  subject_alternative_names = [local.domain_www]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation" {
  for_each = local.is_production ? {
    for dvo in aws_acm_certificate.jlaborda[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.jlaborda[0].zone_id
}

resource "aws_acm_certificate_validation" "jlaborda" {
  count                   = local.is_production ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.jlaborda[0].arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}

resource "aws_route53_record" "apex_a" {
  count   = local.is_production ? 1 : 0
  zone_id = data.aws_route53_zone.jlaborda[0].zone_id
  name    = local.domain_apex
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "apex_aaaa" {
  count   = local.is_production ? 1 : 0
  zone_id = data.aws_route53_zone.jlaborda[0].zone_id
  name    = local.domain_apex
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_a" {
  count   = local.is_production ? 1 : 0
  zone_id = data.aws_route53_zone.jlaborda[0].zone_id
  name    = local.domain_www
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_aaaa" {
  count   = local.is_production ? 1 : 0
  zone_id = data.aws_route53_zone.jlaborda[0].zone_id
  name    = local.domain_www
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.site.domain_name
    zone_id                = aws_cloudfront_distribution.site.hosted_zone_id
    evaluate_target_health = false
  }
}
