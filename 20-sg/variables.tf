variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project     = "expense"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "mysql_sg_tags" {
  default = {
    component = "mysql"
  }
}

variable "backend_sg_tags" {
  default = {
    component = "backend"
  }
}

variable "frontend_sg_tags" {
  default = {
    component = "frontend"
  }
}

variable "bastion_sg_tags" {
  default = {
    component = "bastion"
  }
}

variable "ansible_sg_tags" {
  default = {
    component = "ansible"
  }
}