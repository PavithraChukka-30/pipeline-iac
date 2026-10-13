variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_name" {
  type    = string
  default = "MLR-vpc"
}

variable "sg_name" {
  type    = string
  default = "MLR-sg"
}

variable "instance_name" {
  type    = string
  default = "MLR-ec2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "alb_name" {
  type    = string
  default = "MLR-alb"
}

variable "my_ip_cidr" {
  type = string
}