resource "aws_security_group" "rds" {
    name = "rds-security-group-${var.project}-${var.region}"
    description = "rds Security Group for ${var.project}-${var.region}"
    #vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
    vpc_id = "${var.rds_vpc_id}"
    tags {
        Name = "${var.project}-${var.env_short}-mysql-security-group"
        "SEC_GW" = "${var.rds_sg_tag_sec_gw}"
        "SEC_ECT" = "${var.rds_sg_tag_sec_ect}"
    }
}

resource "aws_security_group_rule" "rds-ingress-cluster" {
    type = "ingress"
    from_port = "${var.rds_port}"
    to_port = "${var.rds_port}"
    protocol = "tcp"
    self = true security_group_id = "${aws_security_group.rds.id}"
    description = "rds-ingress-cluster"
}

resource "aws_security_group_rule" "bastion_ingress_port" {
    type = "ingress"
    to_port = "${var.rds_port}"
    from_port = "${var.rds_port}"
    protocol = "tcp"
    #source_security_group_id = "${data.terraform_remote_state.vpc.vpc_bastion_sg_id}"
    source_security_group_id = "${var.rds_vpc_bastion_sg_id}"
    security_group_id = "${aws_security_group.rds.id}"
    description = "bastion_ingress_port"
}

resource "aws_security_group_rule" "was_ingress_port" {
    type = "ingress"
    to_port = "${var.rds_port}"
    from_port = "${var.rds_port}"
    protocol = "tcp"
    #source_security_group_id = "${data.terraform_remote_state.crp.crp_was_sg_id}"
    source_security_group_id = "${var.rds_crp_was_sg_id}"
    security_group_id = "${aws_security_group.rds.id}"
    description = "was_ingress_port"
}