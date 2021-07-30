variable "region" {
  default = "ap-south-1"
  type = string
}

variable "ami" {
  default = "ami-04db49c0fb2215364"
  type = string
}

variable "master_instance_type" {
  default = "t2.medium"
  type = string
}

variable "worker_instance_type" {
  default = "t2.micro"
  type = string
}

variable "vpc_sg_id" {
  default = ["sg-0344355829b3965a2"]
  type = list
}

variable "keypair" {
  default = "aws-arth-key"
  type = string
}