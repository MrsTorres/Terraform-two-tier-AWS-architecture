# -------- loadbalancing/main.tf

resource "aws_lb_target_group" "lu_alb_tg" {
  name     = "lu-alb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = var.vpc_id
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb" "lu_alb" {
  name               = "lu-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = var.public_subnets
}

# Create Load balancer listner rule
resource "aws_lb_listener" "lu_lb_lst" {
  load_balancer_arn = aws_lb.lu_alb.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lu_alb_tg.arn
  }
}
