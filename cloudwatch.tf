resource "aws_cloudwatch_metric_alarm" "eq_ecs_high_cpu" {
  alarm_name          = "${var.env}-eq-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Average"
  threshold           = "60"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.eq_ecs.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.eq_ecs_scaling.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "eq_ecs_low_cpu" {
  alarm_name          = "${var.env}-eq-ecs-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "360"
  statistic           = "Average"
  threshold           = "20"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.eq_ecs.name}"
  }

  alarm_description = "This metric monitors ECS Instance cpu utilization"
  alarm_actions     = ["${aws_autoscaling_policy.eq_ecs_scaling.arn}"]
}
