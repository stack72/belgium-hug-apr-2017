resource "dnsimple_record" "myapplication" {
  domain = "${var.domain_name}"
  name = "${var.record_name}"
  value = "${var.dns_name}"
  type = "CNAME"
  ttl = "${var.ttl}"
}