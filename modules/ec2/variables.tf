variable "public_subnet_id" {
  type = string
}

variable "ec2_sg_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "rds_endpoint" {
  type = string
}

variable "ami_id" {
  type = string
}
