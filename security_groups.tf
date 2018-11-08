resource "aws_security_group" "alb_waf_access" {
  count       = "${var.create_internal_elb ? 1 : 0}"
  name        = "${var.env}-${var.ecs_cluster_name}-alb-access-from-waf"
  description = "Allow access to the ALB from the WAF"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = "${var.vpc_peer_cidr_block}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.env}-${var.ecs_cluster_name}-ecs"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "alb_ons_access" {
  name        = "${var.env}-${var.ecs_cluster_name}-alb-access-from-ons"
  description = "Allow access to ALB from the ONS"
  vpc_id      = "${var.vpc_id}"
  count       = "${length(var.ons_access_ips) > 0 ? 1 : 0}"

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = "${var.ons_access_ips}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.env}-${var.ecs_cluster_name}-ecs"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "alb_ecs_access" {
  name        = "${var.env}-${var.ecs_cluster_name}-alb-access-from-ecs"
  description = "Allow access to ALB from the ECS cluster"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["${formatlist("%s/32", var.gateway_ips)}"]
  }

  tags {
    Name        = "${var.env}-${var.ecs_cluster_name}-ecs"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "ecs_alb_access" {
  name        = "${var.env}-${var.ecs_cluster_name}-ecs-access-from-alb"
  description = "Allow access from ALB in public subnets"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_subnet.public_subnet.*.cidr_block}"]
  }

  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.ecs_application.*.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.env}-${var.ecs_cluster_name}-ecs"
    Environment = "${var.env}"
  }
}
