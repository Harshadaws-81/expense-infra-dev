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

variable "frontend_tags" {
  default = {
    Component = "frontend"
  }
}

variable "zone_name" {
  default = "harshadaws81s.online"
}

variable "zone_id" {
  default = "Z10285273HTISRK9KKTQT"
}