resource "aws_iam_instance_profile" "ecs" {
  name = "${var.env}_iam_instance_profile_for_${var.ecs_cluster_name}_ecs"
  role = "${aws_iam_role.ecs.name}"
}

resource "aws_iam_role" "ecs" {
  name = "${var.env}_iam_instance_profile_for_${var.ecs_cluster_name}_ecs"

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

data "aws_iam_policy_document" "ecs" {
  statement = {
    "effect" = "Allow"

    "actions" = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
    ]

    "resources" = [
      "arn:aws:ecs:eu-west-1:${data.aws_caller_identity.current.account_id}:cluster/${aws_ecs_cluster.default.name}",
    ]
  }

  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:SubmitContainerStateChange",
      "ecs:SubmitTaskStateChange",
      "ecs:StartTelemetrySession",
    ]

    "resources" = [
      "*",
    ]
  }

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

  "statement" = {
    "effect" = "Allow"

    "actions" = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    "resources" = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "ecs" {
  name   = "${var.env}_iam_instance_profile_for_${var.ecs_cluster_name}_ecs"
  role   = "${aws_iam_role.ecs.id}"
  policy = "${data.aws_iam_policy_document.ecs.json}"
}
