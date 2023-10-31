# BASTION Security Group
resource "aws_security_group" "bastion" {
    name = "${upper(format(" % s - % s - % s - BASTION ",var.bastion_tag_project, var.bastion_name_prefix, var.bastion_tag_environment))}"
    vpc_id = "${var.bastion_vpc_id}"
    tags {
        "Name" = "${upper(format(" % s - % s - % s - BASTION ",var.bastion_tag_project, var.bastion_name_prefix, var.bastion_tag_environment))}"
        "role" = "${var.bastion_tag_role}" "provisioned" = "terraform"
    }
    lifecycle {
        ignore_changes = ["tags", "name"]
    }
}

# All ssh access by explicit IPs
resource "aws_security_group_rule" "in-bastion-ssh" {
    type = "ingress"
    from_port = "${var.bastion_ssh_port}"
    to_port = "${var.bastion_ssh_port}"
    protocol = "tcp"
    cidr_blocks = "${var.bastion_ingress_ips}"
    security_group_id = "${aws_security_group.bastion.id}"
    description = "[SEC_GW] Workspace IPs to access Bastion"
}
   
resource "aws_security_group_rule" "bastion-egress-ssh-port" {
    type = "egress"
    source_security_group_id = "${element(var.bastion_egress_sg_ids, count.index)}"
    from_port = "${var.bastion_ssh_port}"
    to_port = "${var.bastion_ssh_port}"
    protocol = "tcp"
    security_group_id = "${aws_security_group.bastion.id}"
    count = "${var.bastion_name_prefix=="DB - BAS "?var.db_bastion_ssh_egress_sg_id_count:var.ec2_bastion_ssh_egress_sg_id_count}"
    description = "[SEC_GW] Egress rule from ${var.bastion_name_prefix} to ${element(var.bastion_egress_sg_ids, count.index)} in VPC"
}
   
resource "aws_security_group_rule" "bastion-egress-RDS" {
    from_port = "43306"
    protocol = "tcp"
    security_group_id = "${aws_security_group.bastion.id}"
    to_port = "43306"
    type = "egress"
    count = "${var.bastion_name_prefix=="DB - BAS "?1:0}"
    source_security_group_id = "${var.bastion_egress_rds_sg_id}"
    description = "[SEC_GW] Egress rule from ${var.bastion_name_prefix} to ${var.bastion_egress_rds_sg_id}in VPC"
}
   
resource "aws_security_group_rule" "bastion_egress_endpoints" { from_port = 443 protocol = "tcp"
    security_group_id = "${aws_security_group.bastion.id}"
    to_port = 443 type = "egress"
    prefix_list_ids = ["${var.bastion_egress_endpoints_prefixlist_ids}"] description = "[SEC_GW] Egress rule from ${var.bastion_name_prefix} to ${element(var.bastion_egress_endpoints_prefixlist_ids,count.index)} in VPC"
}
   
resource "aws_security_group_rule" "egress-rules-to-symantec-security-group-id" {
    from_port = "${element(var.bastion_to_symantec_ports,count.index)}"
    protocol = "tcp"
    security_group_id = "${aws_security_group.bastion.id}"
    to_port = "${element(var.bastion_to_symantec_ports,count.index)}"
    type = "egress"
    count = "${var.bastion_tag_environment=="prod - uw2 "||var.bastion_tag_environment=="preprod - ue1 "?var.bation_to_symantec_ports_count:0}"
    cidr_blocks = "${var.bastion_to_symantec_vpc_cidr}"
    description = "[SEC_GW] Egress traffic from bastion on port ${element(var.bastion_to_symantec_ports,count.index)} to Symantec server"
}