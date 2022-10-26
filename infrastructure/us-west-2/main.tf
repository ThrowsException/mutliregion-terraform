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
  region = "us-west-2"
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
  image           = "063754174791.dkr.ecr.us-west-2.amazonaws.com/multi-region-app:latest"
  subnets         = ["subnet-0106b7fec64349358", "subnet-038f54f3405dc4c97", "subnet-01878bc7abc305924", "subnet-09f4ca37dcd2cbe02"]
  security_groups = ["sg-0459640ffb16ff3f5"]
  vpc             = "vpc-0c823dd6194ddab5f"
}
