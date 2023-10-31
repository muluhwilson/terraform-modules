data "aws_iam_policy_document" "cloudtrail-iam" {
    statement {
        sid = "AWSCloudTrailAclCheck"

        principals {
            type = "Service"
            identifiers = ["cloudtrail.amazonaws.com"]
        }

        actions = [
            "s3:GetBucketAcl", 
        ]

        resources = [
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}-${var.s3_cloudtrail_namespace}"
        ]
    }

    statement {
        sid = "AWSCloudTrailWrite"

        principals {
            type = "Service"
            identifiers = ["cloudtrail.amazonaws.com"]
        }
        actions = [
            "s3:PutObject",
        ]
        resources = [
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}-${var.s3_cloudtrail_namespace}/*"
        ]

        condition {
            test = "StringEquals"
            variable = "s3:x-amz-acl"

            values = [
                "bucket-owner-full-control"
            ]
        }
    }
}

##########################################
resource "aws_iam_role" "kpgw_env_replica" {
    name = "kpgw_env_replica_role_replication"
    assume_role_policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal":
        {
            "Service": "s3.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }]
}
POLICY

    count = "${var.s3_kpgw_replica_bucket == "" ? 0 : 1}"
}

resource "aws_iam_policy" "kpgw_env_replica" {
    name = "kpgw_env_replica_iam_policy"
    policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": [
            "s3:GetReplicationConfiguration",
            "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}"
        ]
    },
    {
        "Action": [
            "s3:GetObjectVersion",
            "s3:GetObjectVersionAcl"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}/*"
        ]
    },
    {
        "Action": [
            "s3:ReplicateObject",
            "s3:ReplicateDelete"
        ],
        "Effect": "Allow",
        "Resource": "${var.s3_kpgw_replica_bucket}/*"
    }]
}
POLICY
    
    count = "${var.s3_kpgw_replica_bucket == "" ? 0 : 1}"
}

resource "aws_iam_policy_attachment" "kpgw_env_replication" {
    name = "kpgw_env_replica_iam_policy_attachment"
    roles = ["${aws_iam_role.kpgw_env_replica.name}"]
    policy_arn = "${aws_iam_policy.kpgw_env_replica.arn}"

    count = "${var.s3_kpgw_replica_bucket == "" ? 0 : 1}"
}

##########################################
resource "aws_iam_role" "gw_elk_backup_replica" {
    name = "gw_elk_backup_replica_role_replication"

    assume_role_policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Principal": {
            "Service": "s3.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
    }
    ]
}
POLICY

count = "${var.s3_gw_elk_backup_replica_bucket == "" ? 0 : 1}"
}

resource "aws_iam_policy" "gw_elk_backup_replica" {
    name = "gw_elk_backup_replica_iam_policy"
    policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Action": [
            "s3:GetReplicationConfiguration",
            "s3:ListBucket"
        ],
        "Effect": "Allow",
        "Resource": [
            "arn:aws:s3:::gw-elk-backup-${var.s3_environment}"
        ]
    },
    {
        "Action": [
            "s3:GetObjectVersion",
            "s3:GetObjectVersionAcl"
        ],
        "Effect": "Allow",
        "Resource": ["arn:aws:s3:::gw-elk-backup-${var.s3_environment}/*"]
    },
    {
        "Action": [
            "s3:ReplicateObject",
            "s3:ReplicateDelete"
        ],
        "Effect": "Allow",
        "Resource": "${var.s3_gw_elk_backup_replica_bucket}/*"
    }]
}
POLICY

count = "${var.s3_gw_elk_backup_replica_bucket == "" ? 0 : 1}"
}

resource "aws_iam_policy_attachment" "gw_elk_backup_replication" {
    name = "gw_elk_backup_replica_iam_policy_attachment"
    roles = ["${aws_iam_role.gw_elk_backup_replica.name}"]
    policy_arn = "${aws_iam_policy.gw_elk_backup_replica.arn}"
    
    count = "${var.s3_gw_elk_backup_replica_bucket == "" ? 0 : 1}"
}