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

variable "vpc_cidr" {
  default = "27.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = ["27.0.1.0/24", "27.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["27.0.11.0/24", "27.0.12.0/24"]
}

variable "database_subnet_cidrs" {
  default = ["27.0.21.0/24", "27.0.22.0/24"]
}

variable "is_peering_required" {
  default = true
}