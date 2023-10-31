#List of resources exported:
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_zone_aliases" {
  value = module.vpc.zone_aliases
}

output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_private_subnet_ids" {
  value = module.vpc.private_subnets_ids
}

output "vpc_public_subnet_ids" {
  value = module.vpc.public_subnets_ids
}

output "vpc_haproxy_subnet_ids" {
  value = module.vpc.haproxy_subnets_ids
}

output "vpc_database_subnet_ids" {
  value = module.vpc.database_subnets_ids
}

output "vpc_igw_id" {
  value = module.vpc.igw_id
}

output "vpc_nat_eips" {
  value = module.vpc.nat_eips
}

output "vpc_nat_eips_public_ips" {
  value = module.vpc.nat_eips_public_ips
}

output "vpc_natgw_ids" {
  value = module.vpc.nat_gw_ids
}

output "vpc_internal_zone_id" {
  value = module.vpc.r53_internal_zone_id
}

output "vpc_internal_zone_ns" {
  value = module.vpc.r53_internal_zone_ns
}

output "vpc_common_sg_ec2_id" {
  value = module.vpc.vpc_common_sg_ec2_id
}

output "vpc_common_sg_db_id" {
  value = module.vpc.vpc_common_sg_db_id
}

output "vpc_endpoint_network_interface_sg_id" {
  value = module.vpc.vpc_endpoint_network_interface_sg_id
}

output "vpc_common_sg_id" {
  value = module.vpc.vpc_common_sg_id
}

output "vpc_availability_zones" {
  value = module.vpc.vpc_azs
}

#output "vpc_internal_zone_domain" {
#    value = "${module.vpc.r53_internal_zone_domain}"
#}

output "s3_vpc_endpoint_prefixlist_id" {
  value = module.vpc.s3_vpc_endpoint_prefixlist_id
}

output "dynamodb_vpc_endpoint_prefix_list_id" {
  value = module.vpc.dynamodb_vpc_endpoint_prefix_list_id
}

output "vpc_private_route_table_ids" {
  value = ["${module.vpc.private_route_table_ids}"]
}

output "vpc_public_route_table_ids" {
  value = ["${module.vpc.public_route_table_ids}"]
}

output "aws_s3_vpc_endpoint_id" {
  value = module.vpc.aws_s3_vpc_endpoint_id
}
