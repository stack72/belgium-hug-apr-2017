provider "aws" {
  region = "eu-west-1"
}

provider "dnsimple" {}

resource "aws_key_pair" "ssh_key" {
  key_name = "belgiumhug"
  public_key = "${file("../ssh/belgiumhug.pub")}"
}

module "vpc" {
  source = "../modules/vpc"

  name = "belgiumhug"

  cidr = "${var.cidr_block}"

  private_subnets = [
    "${cidrsubnet(var.cidr_block, 3, 5)}", //10.0.160.0/19
    "${cidrsubnet(var.cidr_block, 3, 6)}", //10.0.192.0/19
    "${cidrsubnet(var.cidr_block, 3, 7)}"  //10.0.224.0/19
  ]

  public_subnets = [
    "${cidrsubnet(var.cidr_block, 5, 0)}", //10.0.0.0/21
    "${cidrsubnet(var.cidr_block, 5, 1)}", //10.0.8.0/21
    "${cidrsubnet(var.cidr_block, 5, 2)}"  //10.0.16.0/21
  ]

  availability_zones = ["${data.aws_availability_zones.zones.names}"]
}

module "vpn" {
  source = "../modules/vpn"

  vpc_id = "${module.vpc.vpc_id}"
  public_subnets = ["${module.vpc.public_subnets}"]
  ami = "${var.openvpn_ami_id}"
  key_name = "${aws_key_pair.ssh_key.key_name}"
  tag_name = "belgiumhug"
}

module "application_tier" {
  source  = "../modules/application1"
  private_subnets = ["${module.vpc.private_subnets}"]
  public_subnets = ["${module.vpc.public_subnets}"]
  instance_type = "t2.micro"
  availability_zones = ["${module.vpc.public_availability_zones}"]
  ami = "${data.aws_ami.application_instance_ami.id}"
  vpc_id = "${module.vpc.vpc_id}"
  key_name = "${aws_key_pair.ssh_key.key_name}"

  blue_instance_count = "3"
  green_instance_count = "3"
}

module "dns" {
  source = "../modules/dnsimple"

  domain_name = "${var.domain_name}"
  dns_name = "${module.application_tier.blue_application_elb_address}"
  record_name = "${var.dns_record_name}"
}

data "aws_ami" "application_instance_ami" {
  most_recent = true
  filter {
    name = "name"
    values = ["application_instance-*"]
  }
  filter {
    name = "tag:Version"
    values = ["1.0.1"]
  }
}

data "aws_availability_zones" "zones" {}