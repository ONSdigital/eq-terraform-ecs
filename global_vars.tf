variable "env" {
  description = "The environment you wish to use"
}

variable "aws_secret_key" {
  description = "Amazon Web Service Secret Key"
}

variable "aws_access_key" {
  description = "Amazon Web Service Access Key"
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "ecs_instance_type" {
  description = "ECS Instance Type"
  default     = "t2.medium"
}

variable "ecs_aws_key_pair" {
  description = "Amazon Web Service Key Pair for use by ecs - in production this value should be empty"
  default     = ""
}

variable "ecs_cluster_min_size" {
  description = "ECS Cluster Minimum number of instances"
  default     = "3"
}

variable "ecs_cluster_max_size" {
  description = "ECS Cluster Maximum number of instances"
  default     = "24"
}

variable "vpc_id" {
  description = "The survey runner VPC ID"
}

variable "public_subnet_ids" {
  type        = "list"
  description = "The IDs of the public subnets for the external ELBs"
}

variable "vpc_peer_cidr_block" {
  description = "The CIDR block of the peered VPC, optional"
  default     = "0.0.0.0/0"
}

variable "ecs_application_cidrs" {
  type        = "list"
  description = "CIDR blocks for ecs application subnets"
}

variable "private_route_table_ids" {
  type        = "list"
  description = "Route tables with route to NAT gateway"
}

variable "certificate_arn" {
  description = "ARN of the IAM loaded TLS certificate for public ELB"
}

variable "auto_deploy_updated_tags" {
  description = "Automatically deploy images when tags updated"
  default     = false
}
