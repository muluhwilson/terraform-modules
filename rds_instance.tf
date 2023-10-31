resource "aws_db_subnet_group" "subnet_rds_gw" {
    name = "subnet-rds-gw-${var.project}.${var.env_short}-subnet"
    #subnet_ids = ["${data.terraform_remote_state.vpc.vpc_private_subnet_ids}"]
    subnet_ids = ["${var.rds_vpc_private_subnet_ids}"]

    tags {
        Name = "${var.project} ${var.env_short} mysql"
    }
}

//data "aws_db_cluster_snapshot" "qa_final_snapshot" {
//    db_cluster_identifier = "aurora-${var.project}-${var.env_short}-${count.index}"#
//    skip_final_snapshot = false
//
//}

resource "aws_rds_cluster_instance" "cluster_instances" {
    count = 2
    identifier = "aurora-${var.project}-${var.env_short}-${count.index}"
    cluster_identifier = "${aws_rds_cluster.aurora.id}"
    instance_class = "${var.rds_instance_class}"
    publicly_accessible = false
    db_subnet_group_name = "${aws_db_subnet_group.subnet_rds_gw.id}"
    monitoring_interval = "${var.rds_monitoring_interval}"
    monitoring_role_arn = "${join("", aws_iam_role.rds-enhanced-monitoring.*.arn)}"
    performance_insights_enabled = "${var.performance_insights_enabled}"
    lifecycle {
        ignore_changes = ["snapshot_identifier"]
    }
    tags {
        Name = "${var.project} ${var.env_short} mysql"
        "SEC_ASSETS" = "${var.rds_tag_sec_assets}"
        "SEC_ASSETS_DB" = "${var.rds_tag_sec_assets_db}-${count.index}"
        "SEC_ASSETS_PII" = "${var.rds_tag_sec_assets_pii}"
    }
}

data "aws_iam_policy_document" "monitoring-rds-assume-role-policy" {
    statement {
        actions = ["sts:AssumeRole"] principals
        {
            type = "Service"
            identifiers = ["monitoring.rds.amazonaws.com"]
        }
    }
}

resource "aws_iam_role" "rds-enhanced-monitoring" {
    count = "${var.rds_monitoring_interval > 0 ? 1 : 0}"
    name_prefix = "rds-enhanced-monitoring-${var.env_short}-"
    assume_role_policy = "${data.aws_iam_policy_document.monitoring-rds-assume-role-policy.json}"
}

resource "aws_iam_role_policy_attachment" "rds-enhanced-monitoring-policy-attach" {
    count = "${var.rds_monitoring_interval > 0 ? 1 : 0}"
    role = "${aws_iam_role.rds-enhanced-monitoring.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
} 

//data "aws_db_snapshot" "latest_prod_snapshot" { 
// db_instance_identifier = "asdfa" 
// most_recent = false 
//}

resource "aws_rds_cluster" "aurora" {
    cluster_identifier = "aurora-${var.project}-${var.env_short}-cluster"#
    availability_zones = ["${data.terraform_remote_state.vpc.az-a}", "${data.terraform_remote_state.vpc.az-b}"] db_subnet_group_name = "${aws_db_subnet_group.subnet_rds_gw.id}"
    database_name = "${var.rds_db_name}"
    master_username = "${var.rds_username}"
    master_password = "${var.rds_password}"
    vpc_security_group_ids = ["${aws_security_group.rds.id}"] backup_retention_period = "${var.rds_retention_period}"
    snapshot_identifier = "${var.rds_snapshot_identifier}"
    final_snapshot_identifier = "aurora-${var.project}-${var.env_short}-cluster-final"
    port = "${var.rds_port}"
    availability_zones = "${var.rds_availabilityzones}"
    storage_encrypted = "${var.storage_encrypted}"
    tags {
        Name = "${var.project} ${var.env_short} mysql"
        "SEC_ASSETS" = "${var.rds_tag_sec_assets}"
        "SEC_ASSETS_DB" = "${var.rds_tag_sec_assets_db}"
        "SEC_ASSETS_PII" = "${var.rds_tag_sec_assets_pii}"
    }
}