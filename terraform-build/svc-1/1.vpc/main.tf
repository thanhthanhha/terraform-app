provider "aws" {
  region = var.region_name  # Set your desired AWS region
  alias = "this"
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

data "aws_caller_identity" "current" {}

locals {
  suffix = ${lower(var.svc_name)}
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source = "../../../terraform-modules/module-base/vpc"

  name = "${local.suffix}-${var.region_name}-vpc"
  cidr = var.vpc_cidr_block

  azs                 = var.azs
  private_subnets     = [for k, v in var.azs : cidrsubnet(var.vpc_cidr_block, 8, k)]
  public_subnets      = [for k, v in var.azs : cidrsubnet(var.vpc_cidr_block, 8, k + 4)]
  database_subnets    = [for k, v in var.azs : cidrsubnet(var.vpc_cidr_block, 8, k + 8)]

  private_subnet_names = ["Private Subnet One", "Private Subnet Two"]
  # public_subnet_names omitted to show default name generation for all three subnets
  database_subnet_names    = ["DB Subnet One"]
  elasticache_subnet_names = ["Elasticache Subnet One", "Elasticache Subnet Two"]
  redshift_subnet_names    = ["Redshift Subnet One", "Redshift Subnet Two", "Redshift Subnet Three"]
  intra_subnet_names       = []

  create_database_subnet_group  = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = true
  single_nat_gateway = true

  customer_gateways = {
    IP1 = {
      bgp_asn     = 65112
      ip_address  = "1.2.3.4"
      device_name = "some_name"
    },
    IP2 = {
      bgp_asn    = 65112
      ip_address = "5.6.7.8"
    }
  }

  enable_vpn_gateway = true

  enable_dhcp_options              = true
  dhcp_options_domain_name         = "service.consul"
  dhcp_options_domain_name_servers = ["127.0.0.1", "10.10.0.2"]

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.tags
}
