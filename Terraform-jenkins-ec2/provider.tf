terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16.0"
    }
}   
  backend "s3" {
    bucket = "terraform-backend-86"
    key    = "robo-jenkins"
    region = "us-west-2"
    use_lockfile = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

