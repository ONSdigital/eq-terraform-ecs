data "template_file" "watchtower" {
  template = "${file("${path.module}/task-definitions/watchtower.json")}"

  vars {
    LOG_GROUP = "${aws_cloudwatch_log_group.watchtower.name}"
  }
}

resource "aws_ecs_task_definition" "watchtower" {
  family                = "${var.env}-watchtower"
  container_definitions = "${data.template_file.watchtower.rendered}"

  volume {
    name      = "docker"
    host_path = "/var/run/docker.sock"
  }
}

resource "aws_ecs_service" "watchtower" {
  name            = "${var.env}-watchtower"
  cluster         = "${aws_ecs_cluster.eq.id}"
  task_definition = "${aws_ecs_task_definition.watchtower.family}"
  desired_count   = "${(var.auto_deploy_updated_tags == false ? 0 : var.ecs_cluster_min_size)}"
}

resource "aws_cloudwatch_log_group" "watchtower" {
  name = "${var.env}-watchtower"

  tags {
    Environment = "${var.env}"
  }
}
