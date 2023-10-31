variable "vpc_tag_project" {
  description = "A value for the project tag."
  type        = string
}

variable "vpc_tag_environment" {
  description = "A value for the environment tag."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR range for the VPC."
  type        = string
}

variable "vpc_ssh_port" {
  description = "The ssh port to use."
  type        = string
  default     = "22"
}

variable "vpc_private_subnets" {
  description = "A list of CIDR ranges to apply to the private subnets."
  type        = list(string)
}

variable "vpc_public_subnets" {
  description = "A list of CIDR ranges to apply to the public subnets."
  type        = list(string)
}

variable "vpc_haproxy_subnets" {
  description = "A list of CIDR ranges to apply to the haproxy subnet."
  type        = list(string)
}

variable "vpc_database_subnets" {
  description = "A list of CIDR ranges to apply to the database subnets."
  type        = list(string)
}

variable "vpc_availabilityzones" {
  description = "A list of AWS availability zones to build the VPC in."
  type        = list(string)
}

variable "vpc_enable_dns_hostnames" {
  description = "Turn on/off DNS hostnames in the VPC."
  type        = string
  default     = "true"
}

variable "vpc_enable_dns_support" {
  description = "Turn on/off DNS support in the VPC."
  type        = string
  default     = "true"
}

variable "vpc_enable_nat_gateway" {
  description = "Turn on/off the NAT Gateway in the VPC."
  type        = string
  default     = "true"
}

variable "vpc_flow_log_cloudwatch_log_group" {
  description = "Log group for flow logs of VPC on cloudwatch"
  type        = string
}

variable "vpc_sg_common_prefix" {
  description = "A prefix for the common security group used for ec2 ssh connections."
  type        = string
  default     = "EC2"
}

variable "vpc_account_owner_ip" {
  type = list(string)
}

variable "vpc_terraform_state_bucket" {
  default = ""
}

variable "vpc_emr_routetable_id" {
  description = "Emr Route Table ID"
  type        = string
}

variable "vpc_s3_endpoint_env" {
  description = "The s3 bucket for the s3 endpoint."
  type        = string
  default     = ""
}

variable "region" {
  description = "aws region"
  type        = string
}
