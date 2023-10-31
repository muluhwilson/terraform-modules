resource "aws_s3_bucket_policy" "s3_elb_log_policy" {
    bucket = "${var.s3_profile}-${var.s3_environment}"
    policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${var.s3_account_id}:root"
        },
        "Action": "s3:*",
        "Resource": "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}"
    },
    {
        "Effect": "Allow",
        "Principal":
        {
            "AWS": "arn:aws:iam::${lookup(var.s3_elb_log_accounts,var.aws_region)}:root"
        },
        "Action": "s3:PutObject",
        "Resource": [
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}/crp-elb/AWSLogs/${var.s3_account_id}/*",
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}/crp-alb/AWSLogs/${var.s3_account_id}/*",
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}/elk-elb/AWSLogs/${var.s3_account_id}/*",
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}/zeppelin-elb/AWSLogs/${var.s3_account_id}/*",
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}/zeppelin-alb/AWSLogs/${var.s3_account_id}/*",
            "arn:aws:s3:::${var.s3_profile}-${var.s3_environment}/jenkins-alb/AWSLogs/${var.s3_account_id}/*"
        ]
    }
    ]
}
POLICY

count = "${var.s3_environment == "" ? 0 : 1}"
}

resource "aws_s3_bucket_policy" "s3_cloudtrail_policy-preprod-preprod" {
    bucket = "${var.s3_profile}-preprod-preprod-cloudtrail-logs"
    policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Sid": "AWSCloudTrailAclCheck",
        "Effect": "Allow",
        "Principal": {
            "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::${var.s3_profile}-preprod-preprod-cloudtrail-logs"
    },
    {
        "Sid": "AWSCloudTrailWrite",
        "Effect": "Allow",
        "Principal": {
            "Service": "cloudtrail.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::${var.s3_profile}-preprod-preprod-cloudtrail-logs/*",
        "Condition": {
            "StringEquals": {
                "s3:x-amz-acl": "bucket-owner-full-control"
            }
        }
    }
    ]
}
POLICY
    
    count = "${var.aws_region == "us-east-1" ? (var.s3_account_id == "060671536724 " ? 1 : 0) : 0}"
}

resource "aws_s3_bucket_policy" "getwell-website" {
    bucket = "getwell-website"
    policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::${var.s3_account_id}:role/EC2_General"
        },
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::getwell-website/*"
    }]
}
POLICY
    
    count = "${var.aws_region == "us-west-1" ? (var.s3_account_id == "060671536724 " ? 1 : 0) : 0}"
}

resource "aws_s3_bucket_policy" "elk-logs-export" {
    bucket = "elk-logs-export"
    policy = << POLICY
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
            "Service": "logs.us-west-1.amazonaws.com"
        },
        "Action": "s3:GetBucketAcl",
        "Resource": "arn:aws:s3:::elk-logs-export"
    },
    {
        "Effect": "Allow",
        "Principal":
        {
            "Service": "logs.us-west-1.amazonaws.com"
        },
        "Action": "s3:PutObject",
        "Resource": "arn:aws:s3:::elk-logs-export/elklogsarchive/*",
        "Condition":
        {
            "StringEquals":
            {
                "s3:x-amz-acl": "bucket-owner-full-control"
            }
        }
    }]
}
POLICY
    
    count = "${var.aws_region == "us-west-1" ? (var.s3_account_id == "060671536724 " ? 1 : 0) : 0}"
}