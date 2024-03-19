provider "aws" {
  region = var.region_name  # Set your desired AWS region
}

terraform {
  backend "s3" {
    bucket         = "terraformend"  # Replace with your S3 bucket name
    key            = "tfvars/build/vpc/terraform.tfstate"    # Set the desired path for your state file
    region         = "us-west-2"                         # Set your desired AWS region
    encrypt        = true                                # Optional: Set to true to enable server-side encryption
    dynamodb_table = "terraform-lock-table"              # Optional: Specify a DynamoDB table for state locking
  }
}

provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-vpc"
    GithubOrg  = "terraform-aws-modules"
  }
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../"

  name = local.name
  cidr = var.vpc_cidr

  azs  = var.region_name
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

  tags = local.tags
}

