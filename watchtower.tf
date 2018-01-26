data "template_file" "watchtower" {
  count    = "${(var.auto_deploy_updated_tags == false ? 0 : 1)}"
  template = "${file("${path.module}/task-definitions/watchtower.json")}"

  vars {
    LOG_GROUP = "${aws_cloudwatch_log_group.watchtower.name}"
  }
}

resource "aws_ecs_task_definition" "watchtower" {
  count                 = "${(var.auto_deploy_updated_tags == false ? 0 : 1)}"
  family                = "${var.env}-watchtower"
  container_definitions = "${data.template_file.watchtower.rendered}"
  task_role_arn         = "${aws_iam_role.watchtower.arn}"

  volume {
    name      = "docker"
    host_path = "/var/run/docker.sock"
  }
}

resource "aws_ecs_service" "watchtower" {
  name            = "${var.env}-watchtower"
  count           = "${(var.auto_deploy_updated_tags == false ? 0 : 1)}"
  cluster         = "${aws_ecs_cluster.eq.id}"
  task_definition = "${aws_ecs_task_definition.watchtower.family}"
  desired_count   = "${var.ecs_cluster_min_size}"
}

resource "aws_cloudwatch_log_group" "watchtower" {
  name  = "${var.env}-watchtower"
  count = "${(var.auto_deploy_updated_tags == false ? 0 : 1)}"

  tags {
    Environment = "${var.env}"
  }
}

resource "aws_iam_role" "watchtower" {
  name = "${var.env}_iam_instance_profile_for_watchtower"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "watchtower" {

  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]

    "resources" = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "watchtower" {
  name   = "${var.env}_iam_instance_profile_for_watchtower"
  role   = "${aws_iam_role.watchtower.id}"
  policy = "${data.aws_iam_policy_document.watchtower.json}"
}
