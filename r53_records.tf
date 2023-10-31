#
MySQL "resource" "aws_route53_record" "mysql1" {
  zone_id = var.rds_vpc_internal_zone_id
  name    = "mysql-${var.project}-${var.env_short}"
  type    = "CNAME"
  ttl     = 60
  records = ["${aws_rds_cluster.aurora.endpoint}"]
}
