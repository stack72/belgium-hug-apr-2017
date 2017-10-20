resource "aws_elb" "application_elb_green" {
  name = "application-elb-green"
  subnets = ["${var.public_subnets}"]
  security_groups = ["${aws_security_group.application_elb.id}"]
  instances = ["${aws_instance.green_application_instances.*.id}"]
  cross_zone_load_balancing = true
  connection_draining = true
  internal = false

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    target              = "HTTP:80/index.html"
    timeout             = 5
  }

  tags {
    Name = "Application ELB - Green Cluster"
  }
}

resource "aws_elb" "application_elb_blue" {
  name = "application-elb-blue"
  subnets = ["${var.public_subnets}"]
  security_groups = ["${aws_security_group.application_elb.id}"]
  instances = ["${aws_instance.blue_application_instances.*.id}"]
  cross_zone_load_balancing = true
  connection_draining = true
  internal = false

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    target              = "HTTP:80/index.html"
    timeout             = 5
  }

  tags {
    Name = "Application ELB - Blue Cluster"
  }
}