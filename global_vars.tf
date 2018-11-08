variable "env" {
  description = "The environment you wish to use"
}

variable "aws_account_id" {
  description = "Amazon Web Service Account ID"
}

variable "aws_assume_role_arn" {
  description = "IAM Role to assume on AWS"
}

variable "availability_zones" {
  type        = "list"
  description = "The availability zones"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "ecs_instance_type" {
  description = "ECS Instance Type"
  default     = "c5.xlarge"
}

variable "ecs_instance_storage_size" {
  description = "The root block storage size (in GB) of the EC2 instance"
  default     = 100
}

variable "ecs_aws_key_pair" {
  description = "Amazon Web Service Key Pair for use by ecs - in production this value should be empty"
  default     = ""
}

variable "ecs_cluster_name" {
  description = "A unique name for the ecs cluster"
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
  type        = "list"
  description = "The CIDR block of the peered VPC, optional"
  default     = []
}

variable "ecs_application_cidrs" {
  type        = "list"
  description = "CIDR blocks for ecs application subnets"
}

variable "private_route_table_ids" {
  type        = "list"
  description = "Route tables with route to NAT gateway"
}

variable "gateway_ips" {
  type        = "list"
  description = "A list of External IP addresses for the service"
}

variable "ons_access_ips" {
  type        = "list"
  description = "List of IP's or IP ranges to allow access from ONS"
  default     = []
}

variable "certificate_arn" {
  description = "ARN of the IAM loaded TLS certificate for public ELB"
}

variable "auto_deploy_updated_tags" {
  description = "Automatically deploy images when tags updated"
  default     = "false"
}

variable "create_external_elb" {
  description = "Deploy an external load balancer"
  default     = false
}

variable "create_internal_elb" {
  description = "Deploy an internal load balancer"
  default     = true
}
