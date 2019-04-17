
resource "aws_vpc_endpoint" "private_ecs" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.ecs"
  subnet_ids = ["${aws_subnet.ecs_application.*.id}"]
  security_group_ids = ["${aws_security_group.aws_vpc_endpoint_security_group.id}"]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "private_ecs_agent" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.ecs-agent"
  subnet_ids = ["${aws_subnet.ecs_application.*.id}"]
  security_group_ids = ["${aws_security_group.aws_vpc_endpoint_security_group.id}"]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "private_ecs_telemetry" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.ecs-telemetry"
  subnet_ids = ["${aws_subnet.ecs_application.*.id}"]
  security_group_ids = ["${aws_security_group.aws_vpc_endpoint_security_group.id}"]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "private_ecr" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  subnet_ids = ["${aws_subnet.ecs_application.*.id}"]
  security_group_ids = ["${aws_security_group.aws_vpc_endpoint_security_group.id}"]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "private_ecr_api" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  subnet_ids = ["${aws_subnet.ecs_application.*.id}"]
  security_group_ids = ["${aws_security_group.aws_vpc_endpoint_security_group.id}"]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "private_logs" {
  vpc_id       = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.current.name}.logs"
  subnet_ids = ["${aws_subnet.ecs_application.*.id}"]
  security_group_ids = ["${aws_security_group.aws_vpc_endpoint_security_group.id}"]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true
}

resource "aws_security_group" "aws_vpc_endpoint_security_group" {
  name        = "aws_vpc_endpoint_security_group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.env}-aws_vpc_endpoint_security_group"
  }
}