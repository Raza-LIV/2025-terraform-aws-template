output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}

output "website_endpoint" {
  value       = format("%s.s3-website-%s.amazonaws.com", aws_s3_bucket.website.bucket, var.aws_region)
}
