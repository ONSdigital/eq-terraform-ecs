resource "aws_ecs_cluster" "eq" {
  name = "${var.env}-eq"
}

data "template_file" "ecs_user_data" {
  template = "${file("${path.module}/ecs_instance_user_data.txt")}"

  vars {
    ECS_CLUSTER = "${aws_ecs_cluster.eq.name}"
    FILE_SYSTEM_ID = "${aws_efs_file_system.ecs.id}"
    FILE_SYSTEM_REGION = "${data.aws_region.current.current}"
  }
}

resource "aws_launch_configuration" "ecs" {
  name_prefix            = "${var.env}-eq-ecs-"
  image_id               = "ami-5f140c39" // Amazon ECS-Optimized AMI (see: http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)
  instance_type          = "${var.ecs_instance_type}"
  key_name               = "${var.ecs_aws_key_pair}"
  iam_instance_profile   = "${aws_iam_instance_profile.eq_ecs.id}"
  security_groups        = ["${aws_security_group.eq_ecs.id}"]
  user_data              = "${data.template_file.ecs_user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eq_ecs" {
  name                 = "${var.env}-eq-ecs"
  availability_zones   = ["${var.availability_zones}"]
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  vpc_zone_identifier = ["${aws_subnet.ecs_application.*.id}"]
  min_size             = "${var.ecs_cluster_min_size}"
  max_size             = "${var.ecs_cluster_max_size}"
  desired_capacity     = "${var.ecs_cluster_desired_size}"
}