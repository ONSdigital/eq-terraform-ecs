resource "aws_alb" "eq" {
  name            = "${var.env}-eq-alb"
  internal        = false
  security_groups = ["${aws_security_group.eq_alb.id}"]
  subnets         = ["${var.public_subnet_ids}"]

  tags {
    Name = "survey-runner-alb"
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
    target_group_arn = "${aws_alb_target_group.survey_launcher.arn}"
    type             = "forward"
  }
}