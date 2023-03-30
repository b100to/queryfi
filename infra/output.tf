output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "intra_subnets" {
  description = "List of IDs of intra subnets"
  value       = module.vpc.intra_subnets
}

output "database_allowed_cidr_blocks" {
  description = "List of CIDR blocks of private & intra subnets"
  value       = concat(module.vpc.intra_subnets_cidr_blocks, module.vpc.private_subnets_cidr_blocks)
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}
