variable "region_name" {
	description = "AWS Region"
	default = "us-west-1"
	type = string
}

variable "vpc_id" {
	description = "AWS VPc id"
	default = "vpc-0adb505aa71c205b4"
	type = string
}

variable "vpc_cidrs" {
	description = "AWS VPc id"
	default = "173.26.0/16"
	type = string
}