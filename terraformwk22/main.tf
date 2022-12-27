# --root/main.tf

module "networking" {
  source               = "./networking"
  vpc_cidr             = "172.33.0.0/16"
  access_ip            = var.access_ip
  private_subnet_count = 3
  public_subnet_count  = 3
  private_cidrs        = [for i in range(1, 6, 2) : cidrsubnet("172.33.0.0/16", 8, i)]
  public_cidrs         = [for i in range(2, 7, 2) : cidrsubnet("172.33.0.0/16", 8, i)]
}

module "load_balancer" {
  source            = "./load_balancer"
  lb_sg             = module.networking.lb_sg
  public_subnets    = module.networking.publicsub_1
  vpc_id            = module.networking.vpc_id
  tg_port           = 80
  tg_protocol       = "HTTP"
  listener_port     = 80
  listener_protocol = "HTTP"
}

module "compute" {
  source          = "./compute"
  instance_type   = "t2.micro"
  public_subnets  = module.networking.publicsub_1
  private_subnets = module.networking.privatesub_1
  webserver_sg    = module.networking.private_sg
  bastion_host_sg = module.networking.bastion_host_sg
  key_name        = "mykeys"
  user_data       = filebase64("./bootstrap.sh")
  lb_tg           = module.load_balancer.lb_tg
}