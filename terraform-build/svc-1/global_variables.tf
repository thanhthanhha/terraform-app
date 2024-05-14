variable "region_name" {
	description = "AWS Region"
	default = "us-west-1"
	type = string
}

variable "svc_name" {
	description = "Service name"
	default = "blogapp"
	type = string
}

variable "env" {
	description = "env name"
	default = "dev"
	type = string
}

variable "vpc_cidr_block" {
	description = "vpc cidr name"
	default = "10.0.0.0/16"
	type = string
}

data "aws_availability_zones" "available" {}

variable "azs" {
  description = "List of AWS Availability Zones"
  type        = list(string)
  default     = slice(data.aws_availability_zones.available.names, 0, 3)
}