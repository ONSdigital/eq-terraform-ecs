output "ecs_cluster_name" {
  value = "${aws_ecs_cluster.eq.name}"
}

output "aws_alb_dns_name" {
  value = "${aws_alb.eq.dns_name}"
}

output "aws_alb_listener_arn" {
  value = "${aws_alb_listener.eq.arn}"
}

output "aws_alb_arn" {
  value = "${aws_alb.eq.arn}"
}

output "ecs_subnet_ids" {
  value = "${aws_subnet.ecs_application.*.id}"
}

output "ecs_alb_security_group" {
  value = "${aws_security_group.eq_ecs_alb_access.id}"
}