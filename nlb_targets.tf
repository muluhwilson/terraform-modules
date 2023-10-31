resource "aws_lb_target_group" "nlb_instances" {
  name     = format("%s-%s-%s-nlb-%s-tg", var.tag_project, var.tag_role, var.is_public ? "ext " : "int ", var.tag_environment)
  port     = var.nlb_app_port
  protocol = var.nlb_health_check_protocol
  vpc_id   = var.nlb_vpc_id

  health_check {
    healthy_threshold   = var.nlb_healthy_threshold
    unhealthy_threshold = var.nlb_unhealthy_threshold
    interval            = var.nlb_health_check_interval
  }

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }
}

resource "aws_lb_target_group_attachment" "nlb_instance_list" {
  target_group_arn = aws_lb_target_group.nlb_instances.arn
  target_id        = element(var.nlb_instances, count.index)
  port             = var.nlb_app_port
  count            = var.nlb_instances_count
}
