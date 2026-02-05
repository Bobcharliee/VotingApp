module "vpc" {
  source = "./modules/vpc"
}

module "security_group" {
  source              = "./modules/security_group"
  vpc_id              = module.vpc.vpc_id
  load_balancer_sg_id = module.security_group.load_balancer_sg_id
  app_server_sg_id    = module.security_group.app_server_sg_id
}

module "secret_manager" {
  source      = "./modules/secret_manager"
  db_username = var.db_username
}

module "load_balancer" {
  source              = "./modules/load_balancer"
  vpc_id              = module.vpc.vpc_id
  public_subnet       = module.vpc.public_subnet
  load_balancer_sg_id = module.security_group.load_balancer_sg_id
  private_subnet_1    = module.vpc.private_subnet_1
  private_subnet_2    = module.vpc.private_subnet_2
}

module "ec2" {
  source                  = "./modules/ec2"
  load_balancer_sg_id     = module.security_group.load_balancer_sg_id
  aws_lb_target_group_arn = module.load_balancer.aws_lb_target_group_arn
  app_server_sg_id        = module.security_group.app_server_sg_id
  public_subnet           = module.vpc.public_subnet
  db_secrets_arn          = module.secret_manager.db_secrets_arn
}

module "rds" {
  source           = "./modules/rds"
  db_server_sg_id  = module.security_group.db_server_sg_id
  private_subnets  = module.vpc.private_subnets
  db_username      = var.db_username
  db_password      = module.secret_manager.password_result
  private_subnet_1 = module.vpc.private_subnet_1
  private_subnet_2 = module.vpc.private_subnet_2
}