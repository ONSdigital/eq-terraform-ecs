resource "aws_efs_file_system" "ecs" {
  creation_token = "${var.env}-ecs"

  tags {
    Name = "${var.env}-ecs-storage"
  }
}

resource "aws_efs_mount_target" "ecs" {
  count          = "${length(var.ecs_application_cidrs)}"
  file_system_id = "${aws_efs_file_system.ecs.id}"
  subnet_id      = "${element(aws_subnet.ecs_application.*.id, count.index)}"
}