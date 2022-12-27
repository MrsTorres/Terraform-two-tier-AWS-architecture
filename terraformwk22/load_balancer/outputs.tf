# --loadbalancing/outputs.tf

output "lb_tg" {
  value = aws_lb_target_group.alb_tg.arn 
}

output "alb_dns" {
  value = aws_lb.project_alb.dns_name
}