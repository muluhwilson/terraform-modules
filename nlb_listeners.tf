resource "aws_lb_listener" "port_443" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = var.nlb_port443_response_type
    target_group_arn = aws_lb_target_group.nlb_instances.arn
  }
  count = var.open_443
}
