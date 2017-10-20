resource "aws_alb" "eq" {
  name            = "${var.env}-eq-alb"
  internal        = false
  security_groups = ["${aws_security_group.eq_alb_ecs_access.id}", "${join("", aws_security_group.eq_alb_waf_access.*.id)}", "${join("", aws_security_group.eq_alb_ons_access.*.id)}"]
  subnets         = ["${var.public_subnet_ids}"]

  tags {
    Name        = "survey-runner-alb"
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener" "eq" {
  load_balancer_arn = "${aws_alb.eq.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.default_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "default_target_group" {
  name     = "${var.env}-default-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}
