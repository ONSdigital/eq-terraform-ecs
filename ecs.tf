resource "aws_ecs_cluster" "eq" {
  name = "${var.env}-eq"
}

data "template_file" "ecs_user_data" {
  template = "${file("${path.module}/templates/ecs_launch_config.tpl")}"

  vars {
    ECS_CLUSTER = "${aws_ecs_cluster.eq.name}"
  }
}

data "aws_ami" "amazon_ecs_ami" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  name_regex = ".+-amazon-ecs-optimized$"

  most_recent = true
}


resource "aws_launch_configuration" "ecs" {
  name_prefix          = "${var.env}-eq-ecs-"
  image_id             = "${data.aws_ami.amazon_ecs_ami.id}"
  instance_type        = "${var.ecs_instance_type}"
  key_name             = "${var.ecs_aws_key_pair}"
  iam_instance_profile = "${aws_iam_instance_profile.eq_ecs.id}"
  security_groups      = ["${aws_security_group.eq_ecs_alb_access.id}"]
  user_data            = "${data.template_file.ecs_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eq_ecs" {
  name                 = "${var.env}-eq-ecs"
  availability_zones   = ["${var.availability_zones}"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  vpc_zone_identifier  = ["${aws_subnet.ecs_application.*.id}"]
  min_size             = "${var.ecs_cluster_min_size}"
  max_size             = "${var.ecs_cluster_max_size}"

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  tag {
    key                 = "Name"
    value               = "${var.env}-eq-ecs"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "eq_ecs_scaling" {
  name                      = "${var.env}-eq-ecs-scaling"
  autoscaling_group_name    = "${aws_autoscaling_group.eq_ecs.name}"
  adjustment_type           = "ChangeInCapacity"
  policy_type               = "StepScaling"
  estimated_instance_warmup = "30"

  step_adjustment {
    metric_interval_lower_bound = 0
    metric_interval_upper_bound = 10
    scaling_adjustment          = 1
  }

  step_adjustment {
    metric_interval_lower_bound = 10
    metric_interval_upper_bound = 20
    scaling_adjustment          = 2
  }

  step_adjustment {
    metric_interval_lower_bound = 20
    scaling_adjustment          = 3
  }

  step_adjustment {
    metric_interval_upper_bound = 0
    scaling_adjustment          = -1
  }
}
