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

variable "zone_name" {
  default = "harshadaws81s.online"
}

variable "app_alb_tags" {
  default = {
    Component = "app-alb"
  }
}