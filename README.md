# eq-terraform-ecs

Terraform project that creates the AWS ECS infrastructure for the EQ Survey-Runner

To import this module add the following code into you Terraform project

```
module "survey-runner-ecs" {
  source = "github.com/ONSdigital/eq-terraform-ecs"
  env = "${var.env}"
  aws_access_key = "${var.aws_access_key}"
  aws_secret_key = "${var.aws_secret_key}"
  dns_zone_id = "${var.dns_zone_id}"
  dns_zone_name = "${var.dns_zone_name}"
  certificate_arn = "${var.certificate_arn}"
  vpc_id = "${module.survey-runner-vpc.vpc_id}"
  public_subnet_ids = "${module.survey-runner-routing.public_subnet_ids}"
  ecs_application_cidrs = "${var.ecs_application_cidrs}"
  private_route_table_ids = "${module.survey-runner-routing.private_route_table_ids}"
}
```

To run this module on its own run the following code. (Replacing 'XXX' with you values)

```
terraform apply -var "env=XXX" \
                -var "aws_access_key=XXX" \
                -var "aws_secret_key=XXX" \
                -var "dns_zone_id=XXX" \
                -var "dns_zone_name=XXX" \
                -var "certificate_arn=XXX" \
                -var "vpc_id=XXX" \
                -var "public_subnet_ids=XXX" \
                -var "ecs_application_cidrs=XXX" \
                -var "private_route_table_ids=XXX" \
                -var "private_route_table_ids=XXX" \
```