terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.0"
    }
  }
  backend "s3" {

    region = "ap-south-1"
    dynamodb_table = "terraform-state-table"
    
  }
}

provider "aws" {
  region = var.aws_region

}