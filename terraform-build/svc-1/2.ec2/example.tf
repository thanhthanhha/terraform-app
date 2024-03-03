provider "aws" {
  region = var.region_name
}

terraform {
  backend "s3" {
    bucket         = "terraformend"  # Replace with your S3 bucket name
    key            = "tfvars/build/vpc/terraform.tfstate"    # Set the desired path for your state file
    region         = "ap-southeast-1"                         # Set your desired AWS region
    encrypt        = true                                # Optional: Set to true to enable server-side encryption
    dynamodb_table = "terraform-test"              # Optional: Specify a DynamoDB table for state locking
  }
}

data "aws_availability_zones" "available" {}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_ami" "amazon_linux_23" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

data "aws_vpc" "personal_vpc" {
  id = var.vpc_id 
}

module "security_group" {
  source  = "../../../terraform-modules/modules-base/security/security-group/"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}


locals {
  name   = "ex-${basename(path.cwd)}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  user_data = <<-EOT
    #!/bin/bash
    echo "Hello Terraform!"
  EOT

  tags = {
    App       = "Terraform"
    Project   = "BlogApp"
  }
}

module "ec2_complete" {
  source = "../../../terraform-modules/modules-base/compute/ec2"

  name = local.name

  ami                         = data.aws_ami.amazon_linux_23.id
  instance_type               = "t2.micro" # used to set core count below
  availability_zone           = element(data.aws_availability_zones.available.names, 0)
  subnet_id                   = element(data.aws_subnets.subnets.ids, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  disable_api_stop            = false

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
  }

  # only one of these can be enabled at a time
  hibernation = true
  # enclave_options_enabled = true

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true

  cpu_options = {
    core_count       = 1
    threads_per_core = 1
  }
  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 50
      tags = {
        Name = "my-root-block"
      }
    },
  ]

  ebs_block_device = [
    {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 5
      tags = {
        MountPoint = "/mnt/data"
      }
    }
  ]

  tags = local.tags
}

##############Template data################

