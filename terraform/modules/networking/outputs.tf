output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "Private subnet IDs for EKS nodes"
  value       = [for s in aws_subnet.private : s.id]
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of public subnets"
  value       = [for s in aws_subnet.public : s.cidr_block]
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of private subnets"
  value       = [for s in aws_subnet.private : s.cidr_block]
}