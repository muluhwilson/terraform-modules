#########################################
# kpgw_env 
resource "aws_s3_bucket" "kpgw_env" {
  bucket = "${var.s3_profile}-${var.s3_environment}"
  acl    = "private"
  policy = aws_s3_bucket_policy.s3_elb_log_policy.policy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    mfa_delete = false
  }

  tags {
    Name        = "${var.s3_profile}-${var.s3_environment}"
    Environment = var.s3_environment
    Provisioned = "terraform"
  }

  count = var.s3_environment == "" ? 0 : (var.s3_kpgw_replica_bucket == "" ? 1 : 0)
}

resource "aws_s3_bucket" "kpgw_env_replica" {
  bucket = "${var.s3_profile}-${var.s3_environment}"
  acl    = "private"
  policy = aws_s3_bucket_policy.s3_elb_log_policy.policy

  versioning {
    enabled    = true
    mfa_delete = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  replication_configuration {
    role = aws_iam_role.kpgw_env_replica.arn
    rules {
      prefix = var.s3_kpgw_replica_bucket_prefix
      status = "Enabled"
      destination {
        bucket        = var.s3_kpgw_replica_bucket
        storage_class = "STANDARD"
      }
    }
  }

  tags {
    Name        = "${var.s3_profile}-${var.s3_environment}"
    Environment = var.s3_environment
    Provisioned = "terraform"
  }

  count = var.s3_environment == "" ? 0 : (var.s3_kpgw_replica_bucket == "" ? 0 : 1)
}

#########################################
# gw - elk - backup 
resource "aws_s3_bucket" "gw-elk-backup" {
  bucket = "gw-elk-backup-${var.s3_environment}"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name        = "gw-elk-backup-${var.s3_environment}"
    Environment = var.s3_environment
    Provisioned = "terraform"
  }
  count = var.s3_environment == "" ? 0 : (var.s3_gw_elk_backup_replica_bucket == "" ? 1 : 0)
}


resource "aws_s3_bucket" "gw-elk-backup-replica" {
  bucket = "gw-elk-backup-${var.s3_environment}"
  acl    = "private"

  replication_configuration {
    role = aws_iam_role.gw_elk_backup_replica.arn
    rules {
      prefix = var.s3_gw_elk_backup_replica_bucket_prefix
      status = "Enabled"
      destination {
        bucket        = var.s3_gw_elk_backup_replica_bucket
        storage_class = "STANDARD"
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name        = "gw-elk-backup-${var.s3_environment}"
    Environment = var.s3_environment
    Provisioned = "terraform"
  }

  count = var.s3_environment == "" ? 0 : (var.s3_gw_elk_backup_replica_bucket == "" ? 0 : 1)
}

#########################################
# cloudtrail - logs 
resource "aws_s3_bucket" "cloudtrail-logs" {
  bucket        = "${var.s3_profile}-${var.s3_environment}-${var.s3_cloudtrail_namespace}"
  force_destroy = true
  policy        = data.aws_iam_policy_document.cloudtrail-iam.json

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags {
    Name        = "${var.s3_profile}-${var.s3_environment}-${var.s3_cloudtrail_namespace}"
    Environment = var.s3_environment
    Provisioned = "terraform"
  }

  count = var.s3_environment == "" ? 0 : 1
}
