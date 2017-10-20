resource "aws_security_group" "eq_alb_waf_access" {
  name        = "${var.env}-eq-alb-access-from-waf"
  description = "Allow access to the ALB from the WAF"
  vpc_id      = "${var.vpc_id}"
  count       = "${length(var.vpc_peer_cidr_block) > 0 ? 1 : 0}"

  ingress {
    from_port   = "443"
    to_port     = "443"
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
    Name        = "${var.env}-eq-ecs"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "eq_alb_ons_access" {
  name        = "${var.env}-eq-alb-access-from-ons"
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
    Name        = "${var.env}-eq-ecs"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "eq_alb_ecs_access" {
  name        = "${var.env}-eq-alb-access-from-ecs"
  description = "Allow access to ALB from the ECS cluster"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["${formatlist("%s/32", var.eq_gateway_ips)}"]
  }

  tags {
    Name        = "${var.env}-eq-ecs"
    Environment = "${var.env}"
  }
}

resource "aws_security_group" "eq_ecs_alb_access" {
  name        = "${var.env}-eq-ecs-access-from-alb"
  description = "Allow access from ALB in public subnets"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = "0"
    to_port     = "65535"
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_subnet.public_subnet.*.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.env}-eq-ecs"
    Environment = "${var.env}"
  }
}
