variable "subnet_cidr_block" {
  default = "10.0.10.0/24"
}
variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}
variable "avail_zone" {
  default = "us-west-1b"
}
variable "env_prefix" {
  default = "dev"
}
variable "my_ip" {
  default = "24.18.157.189/32"
}
variable "jenkins_ip" {
  default = "159.223.197.99/32"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "region" {
  default = "us-west-1"
}