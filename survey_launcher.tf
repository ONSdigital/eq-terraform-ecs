resource "aws_alb_target_group" "survey_launcher" {
  depends_on = ["aws_alb.eq"]
  name     = "${var.env}-survey-launcher-ecs"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"
  health_check = {
    interval = 5
    timeout = 2
  }

  tags {
    Environment = "${var.env}"
  }
}

resource "aws_alb_listener_rule" "survey_launcher" {
  listener_arn = "${aws_alb_listener.eq.arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_alb_target_group.survey_launcher.arn}"
  }

  condition {
    field  = "host-header"
    values = ["${aws_route53_record.survey_launcher.name}"]
  }
}

resource "aws_route53_record" "survey_launcher" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.env}-surveys-launch.${var.dns_zone_name}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_alb.eq.dns_name}"]
}

data "template_file" "survey_launcher" {
  template = "${file("${path.module}/task-definitions/survey-launcher.json")}"

  vars {
    SURVEY_RUNNER_URL = "https://${var.env}-surveys.${var.dns_zone_name}"
  }
}

resource "aws_ecs_task_definition" "survey_launcher" {
  family                = "${var.env}-survey-launcher"
  container_definitions = "${data.template_file.survey_launcher.rendered}"
}

resource "aws_ecs_service" "survey_launcher" {
  depends_on = ["aws_alb_target_group.survey_launcher"]
  name            = "${var.env}-survey-launcher"
  cluster         = "${aws_ecs_cluster.eq.id}"
  task_definition = "${aws_ecs_task_definition.survey_launcher.arn}"
  desired_count   = 3
  iam_role        = "${aws_iam_role.survey_launcher.arn}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.survey_launcher.arn}"
    container_name = "survey-launcher"
    container_port = 8000
  }
}

resource "aws_iam_role" "survey_launcher" {
  name = "${var.env}_iam_for_survey_launcher"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "survey_launcher" {
  "statement" = {
      "effect" = "Allow",
      "actions" = [
        "elasticloadbalancing:*",
      ],
      "resources" = [
        "*"
      ]
    }
}

resource "aws_iam_role_policy" "survey_launcher" {
  name = "${var.env}_iam_for_survey_launcher"
  role = "${aws_iam_role.survey_launcher.id}"
  policy = "${data.aws_iam_policy_document.survey_launcher.json}"
}
