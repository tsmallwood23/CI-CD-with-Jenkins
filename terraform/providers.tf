terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.24.0"
    }
  }
  required_version = ">=0.12"
  backend "s3" {
    bucket = "myapp-bucket2323"
    key = "myapp/state.tfstate"
    region = "us-west-1"
  }
}
