resource "aws_lb" "nlb" {
  name                             = format("%s-%s-%s-%s-%s", var.tag_project, var.tag_role, var.is_public == "1 " ? "ext " : "int ", var.tag_service, var.tag_environment)
  load_balancer_type               = "network"
  subnets                          = ["${var.nlb_subnets}"]
  enable_cross_zone_load_balancing = true
  // idle_timeout = "${var.nlb_idle_timeout}"
  internal = var.is_public == "1" ? false : true

  access_logs {
    bucket  = var.nlb_access_logs_bucket_name
    prefix  = var.nlb_access_logs_bucket_prefix
    enabled = false
  }

  tags {
    Name = (format("%s-%s-%s-%s-%s",
    var.tag_project, var.tag_role, var.is_public == "1" ? "ext" : "int", var.tag_service, var.tag_environment))
    service      = var.tag_service
    role         = var.tag_role
    environment  = var.tag_environment
    first_owner  = var.tag_primary_owner
    second_owner = var.tag_secondary_owner
    time_frame   = var.tag_timeframe
    provisioned  = "terraform"
    project      = var.tag_project
  }
}
