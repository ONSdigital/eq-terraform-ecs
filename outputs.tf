output "ecs_cluster_name" {
  value = "${aws_ecs_cluster.default.name}"
}

output "aws_alb_dns_name" {
  value = "${aws_alb.default.*.dns_name[0]}"
}

output "aws_external_alb_listener_arn" {
  value = "${aws_alb_listener.default.*.arn[0]}"
}

output "aws_external_alb_arn" {
  value = "${aws_alb.default.*.arn[0]}"
}

output "aws_internal_alb_listener_arn" {
  value = "${aws_alb_listener.internal.*.arn}"
}

output "aws_internal_alb_arn" {
  value = "${aws_alb.internal.*.arn}"
}

output "ecs_subnet_ids" {
  value = "${aws_subnet.ecs_application.*.id}"
}

output "ecs_alb_security_group" {
  value = "${aws_security_group.ecs_alb_access.id}"
}
