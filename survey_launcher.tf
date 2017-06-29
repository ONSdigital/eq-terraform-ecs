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
    JWT_ENCRYPTION_KEY_PATH = "${var.jwt_encryption_key_path}"
    JWT_SIGNING_KEY_PATH = "${var.jwt_signing_key_path}"
    SECRETS_S3_BUCKET = "${var.s3_secrets_bucket}"
    LOG_GROUP = "${aws_cloudwatch_log_group.survey_launcher.name}"
    CONTAINER_TAG = "${var.survey_launcher_tag}"
  }
}

resource "aws_ecs_task_definition" "survey_launcher" {
  family                = "${var.env}-survey-launcher"
  container_definitions = "${data.template_file.survey_launcher.rendered}"
  task_role_arn         = "${aws_iam_role.survey_launcher_task.arn}"
}

resource "aws_ecs_service" "survey_launcher" {
  depends_on = ["aws_alb_target_group.survey_launcher"]
  name            = "${var.env}-survey-launcher"
  cluster         = "${aws_ecs_cluster.eq.id}"
  task_definition = "${aws_ecs_task_definition.survey_launcher.arn}"
  desired_count   = 1
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


resource "aws_iam_role" "survey_launcher_task" {
  name = "${var.env}_iam_for_survey_launcher_task"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs-tasks.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "survey_launcher_task" {
  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "s3:GetObject",
      "s3:ListObjects",
      "s3:ListBucket"
    ]

    "resources" = [
      "arn:aws:s3:::${var.s3_secrets_bucket}",
      "arn:aws:s3:::${var.s3_secrets_bucket}/*",
    ]
  }
}

resource "aws_iam_role_policy" "survey_launcher_task" {
  name = "${var.env}_iam_for_survey_launcher_task"
  role = "${aws_iam_role.survey_launcher_task.id}"
  policy = "${data.aws_iam_policy_document.survey_launcher_task.json}"
}

resource "aws_cloudwatch_log_group" "survey_launcher" {
  name = "${var.env}-survey-launcher"

  tags {
    Environment = "${var.env}"
  }
}