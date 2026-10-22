output "distribution_id" {
  description = "CloudFront distribution id for this environment."
  value       = aws_cloudfront_distribution.site.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN. The deploy role may create invalidations only for this ARN."
  value       = aws_cloudfront_distribution.site.arn
}

output "bucket_name" {
  description = "Private site bucket name."
  value       = aws_s3_bucket.site.bucket
}

output "domain_name" {
  description = "CloudFront hostname, without a scheme or a trailing slash."
  value       = aws_cloudfront_distribution.site.domain_name
}
