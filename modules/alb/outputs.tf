output "lb_arn" {
  value = aws_lb.this.arn
}

output "lb_dns_name" {
  value       = aws_lb.this.dns_name
}

output "lb_hosted_zone_id" {
  value       = aws_lb.this.zone_id
}
