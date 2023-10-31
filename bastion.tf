module "bastion" {
  source = "git::ssh://git@github.sec.samsung.net/CO-shealth/TF_Module_EC2"

  nodes_qty                   = var.bastion_qty
  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  iam_instance_profile        = var.bastion_iam_role
  aws_key_pair_name           = var.bastion_key_pair
  subnet_ids                  = ["${var.bastion_public_subnets_ids}"]
  ec2_internal_hosted_zone_id = var.bastion_hosted_zone_id
  has_public_ip               = var.bastion_with_public_ip
  ec2_sg_list                 = ["${var.bastion_security_group_ids}", "${aws_security_group.bastion.id}"]
  ec2_user_data               = file(var.bastion_user_data)
  ebs_optimized               = var.bastion_ebs_optimized

  tag_project            = var.bastion_tag_project
  tag_environment        = var.bastion_tag_environment
  tag_service            = var.bastion_name_prefix
  tag_role               = var.bastion_tag_role
  tag_zones              = ["${var.bastion_tag_zones}"]
  tag_purpose            = var.bastion_tag_purpose
  tag_timeframe          = var.bastion_tag_timeframe
  tag_first_owner        = var.bastion_tag_first_owner
  tag_second_owner       = var.bastion_tag_second_owner
  tag_sec_assets_gateway = var.bastion_tag_sec_assets_gateway
  tag_sec_assets         = var.bastion_tag_sec_assets
}
