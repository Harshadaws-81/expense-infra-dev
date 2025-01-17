module "mysql_sg" {
  #source = "../terraform-aws-security-group"
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "mysql"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.mysql_sg_tags
}

module "backend_sg" {
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "backend"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.backend_sg_tags
}

module "frontend_sg" {
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "frontend"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.frontend_sg_tags
}

# mysql allowing connections on 3306 from the instances attached to backend sg
resource "aws_security_group_rule" "mysql_backend" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.backend_sg.id
  security_group_id        = module.mysql_sg.id
}

# # backend allowing connections on 8080 from the instances attached to frontend sg
# resource "aws_security_group_rule" "backend_frontend" {
#   type                     = "ingress"
#   from_port                = 8080
#   to_port                  = 8080
#   protocol                 = "tcp"
#   source_security_group_id = module.frontend_sg.id
#   security_group_id        = module.backend_sg.id
# }

# # frontend allowing connections on 80 from the instances attached to public
# resource "aws_security_group_rule" "forntend_public" {
#   type              = "ingress"
#   from_port         = 80
#   to_port           = 80
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = module.frontend_sg.id
# } 

module "bastion_sg" {
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "bastion"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.bastion_sg_tags
}

resource "aws_security_group_rule" "mysql_bastion" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id        = module.mysql_sg.id
}

resource "aws_security_group_rule" "backend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id        = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id        = module.frontend_sg.id
}

# Ansible

module "ansible_sg" {
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "ansible"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.ansible_sg_tags
}

# resource "aws_security_group_rule" "mysql_ansible" {
#   type                     = "ingress"
#   from_port                = 22
#   to_port                  = 22
#   protocol                 = "tcp"
#   source_security_group_id = module.ansible_sg.id
#   security_group_id        = module.mysql_sg.id
# }

resource "aws_security_group_rule" "backend_ansible" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.ansible_sg.id
  security_group_id        = module.backend_sg.id
}

resource "aws_security_group_rule" "frontend_ansible" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.ansible_sg.id
  security_group_id        = module.frontend_sg.id
}

resource "aws_security_group_rule" "ansible_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ansible_sg.id
}

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion_sg.id
}

# BACKEND LOAD BALANCER SECURITY GROUP

module "app_alb_sg" {
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "app_alb" # expense-dev-app-alb
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.app_alb_sg_tags
}

resource "aws_security_group_rule" "backend_app_alb" { # backend is accepting connections from app_alb
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.app_alb_sg.id
  security_group_id        = module.backend_sg.id # target
}

resource "aws_security_group_rule" "app_alb_bastion" { # app_alb is accepting connections from bastion
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.bastion_sg.id
  security_group_id        = module.app_alb_sg.id # target
}

# VPN Security_Group
module "vpn_sg" {
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "vpn"
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
}
# Accepting connections from ports - 22 , 943 , 443 , 1194
resource "aws_security_group_rule" "vpn_public_22" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "vpn_public_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

resource "aws_security_group_rule" "app_alb_vpn" { # app_alb is accepting connections from vpn
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id        = module.app_alb_sg.id # target
}

resource "aws_security_group_rule" "backend_vpn" { # Backend is accepting connections from vpn
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id        = module.backend_sg.id # target
}

resource "aws_security_group_rule" "backend_vpn_8080" { # Backend is accepting connections from vpn_8080
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id        = module.backend_sg.id # target
}

# # WEB-ALB
module "web_alb_sg" {
  source       = "git::https://github.com/Harshadaws-81/terraform-aws-security-group.git?ref=main"
  project_name = var.project_name
  environment  = var.environment
  sg_name      = "web-alb" #expense-dev-web-alb
  vpc_id       = local.vpc_id
  common_tags  = var.common_tags
  sg_tags      = var.web_alb_sg_tags
}

resource "aws_security_group_rule" "web_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.id
}

resource "aws_security_group_rule" "web_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.id
}

resource "aws_security_group_rule" "frontend_vpn" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.vpn_sg.id
  security_group_id        = module.frontend_sg.id
}

resource "aws_security_group_rule" "frontend_web_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.web_alb_sg.id
  security_group_id        = module.frontend_sg.id
}

resource "aws_security_group_rule" "app_alb_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = module.frontend_sg.id
  security_group_id        = module.app_alb_sg.id
}
