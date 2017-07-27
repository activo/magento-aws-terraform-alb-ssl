variable "tag_name"           {}
variable "ssl_domain"         {}
variable "web_instance_id"    {}
variable "vpc_id"             {}
variable "security_groups"    { default = [] }
variable "public_subnet_ids"  { default = [] }
variable "enable_deletion_protection" { default = true }

# Use a certificate (needs to be triggered manually from aws)
data "aws_acm_certificate" "default" {
  domain = "${var.ssl_domain}"
  statuses = ["ISSUED", "PENDING_VALIDATION"]
}

# Our load balancer
resource "aws_alb" "front_end" {
  name            = "${var.tag_name}-alb"
  internal        = false
  security_groups = ["${var.security_groups}"]
  subnets         = ["${var.public_subnet_ids}"]
  idle_timeout    = 600

  enable_deletion_protection = "${var.enable_deletion_protection}"
}

resource "aws_alb_target_group" "tg-http" {
  name     = "${var.tag_name}-alb-tg-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

}

resource "aws_alb_target_group_attachment" "alb-tg-attachement" {
  target_group_arn = "${aws_alb_target_group.tg-http.arn}"
  target_id = "${var.web_instance_id}"
  port = 80
}

resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = "${aws_alb.front_end.arn}"
  port = "80"
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.tg-http.arn}"
    type = "forward"
  }
}

resource "aws_alb_listener" "alb_listener_https" {
  load_balancer_arn = "${aws_alb.front_end.arn}"
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${data.aws_acm_certificate.default.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.tg-http.arn}"
    type = "forward"
  }
}
