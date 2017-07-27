
output "alb_dns_name" {
  value = "${aws_alb.front_end.dns_name}"
}

output "alb_zone_id" {
  value = "${aws_alb.front_end.zone_id}"
}
