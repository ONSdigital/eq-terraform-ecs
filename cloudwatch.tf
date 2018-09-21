resource "aws_cloudwatch_metric_alarm" "ecs_high_cpu" {
  alarm_name          = "${var.env}-${var.ecs_cluster_name}-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_scaling.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "ecs_low_cpu" {
  alarm_name          = "${var.env}-${var.ecs_cluster_name}-ecs-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "360"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.ecs_scaling.arn}"]
}
