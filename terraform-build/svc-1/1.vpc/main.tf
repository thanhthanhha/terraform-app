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


