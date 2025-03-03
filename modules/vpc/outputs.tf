output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets_ids" {
  value = aws_subnet.public[*].id
}

output "public_rt" {
  value = aws_route_table.public_rt.id
}
