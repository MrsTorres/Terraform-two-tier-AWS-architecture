# --- networking/outputs.tf ---

output "vpc_id" {
  value = aws_vpc.Week22_vpc.id
}

output "publicsub_1" {
  value = aws_subnet.publicsub_1.*.id
}

output "privatesub_1" {
  value = aws_subnet.privatesub_1.*.id
}

output "bastion_host_sg" {
  value = aws_security_group.bastion_pub_sg.id
}

output "private_sg" {
  value = aws_security_group.private_sg.id
}

output "lb_sg" {
  value = aws_security_group.lb_sg.id
}