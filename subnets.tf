# Private application subnets for apps
resource "aws_subnet" "ecs_application" {
  count             = "${length(var.ecs_application_cidrs)}"
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${var.ecs_application_cidrs[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags {
    Name        = "${var.env}-ecs-application-subnet-${count.index+1}"
    Environment = "${var.env}"
    Type        = "Application"
  }
}

# Associate subnets with route table to NAT gateway
resource "aws_route_table_association" "private" {
  count          = "${length(var.ecs_application_cidrs)}"
  subnet_id      = "${element(aws_subnet.ecs_application.*.id, count.index)}"
  route_table_id = "${var.private_route_table_ids[count.index]}"
}
