// Externally accessible ALB 
resource "aws_alb" "default" {
  count           = "${var.create_external_elb ? 1 : 0}"
  name            = "${var.env}-${var.ecs_cluster_name}-external-alb"
  internal        = false
  security_groups = ["${aws_security_group.alb_ecs_access.id}", "${join("", aws_security_group.alb_ons_access.*.id)}"]
  subnets         = ["${var.public_subnet_ids}"]

  tags {
    Name        = "${var.ecs_cluster_name}-external-alb"
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener" "default" {
  count             = "${var.create_external_elb ? 1 : 0}"
  load_balancer_arn = "${aws_alb.default.arn}"
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
  name     = "${var.env}-${var.ecs_cluster_name}-dtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}

// Internal ALB for WAF
resource "aws_alb" "internal" {
  count           = "${var.create_internal_elb ? 1 : 0}"
  name            = "${var.env}-${var.ecs_cluster_name}-internal-alb"
  internal        = true
  security_groups = ["${aws_security_group.ecs_alb_access.id}", "${join("", aws_security_group.alb_waf_access.*.id)}"]
  subnets         = ["${var.public_subnet_ids}"]

  tags {
    Name        = "${var.ecs_cluster_name}-internal-alb"
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener" "internal" {
  count             = "${var.create_internal_elb ? 1 : 0}"
  load_balancer_arn = "${aws_alb.internal.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.internal_default_target_group.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "internal_default_target_group" {
  name     = "${var.env}-${var.ecs_cluster_name}-internal-dtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
}
