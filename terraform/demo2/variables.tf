variable "cidr_block" {
  default = "10.1.0.0/16"
}

variable "openvpn_ami_id" {
  default = "ami-f53d7386"
}
variable "domain_name" {
  default = "hashicorptest.com"
}
variable "dns_record_name" {
  default = "belgian-hug-2"
}