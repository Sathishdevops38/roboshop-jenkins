variable "project_name" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}
variable "tags" {
  default = {
    created_by = "Terraform"
  }
}

variable "instance_type"{
  default = "t3.micro"
}

variable "domain_name"{
  default = "daws38sat.fun"
}

variable "zone_id" {
  default = "Z041507112WH8TKZP9NS3"
}

