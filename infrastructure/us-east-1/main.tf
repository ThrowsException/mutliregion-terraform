terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      "source" = "terraform"
    }
  }
}

module "ecr" {
  source = "../modules/ecr"
}

module "fargate" {
  source          = "../modules/ecs"
  image           = "063754174791.dkr.ecr.us-east-1.amazonaws.com/multi-region-app:latest"
  subnets         = ["subnet-824b55e6", "subnet-88595ca7"]
  security_groups = ["sg-94b080e2"]
  vpc             = "vpc-fc8d1f87"
}
