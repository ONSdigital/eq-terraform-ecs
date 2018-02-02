provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "eu-west-1"
}

data "aws_caller_identity" "current" {}

data "aws_subnet" "public_subnet" {
  count = 3
  id    = "${var.public_subnet_ids[count.index]}"
}
