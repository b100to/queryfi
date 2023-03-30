terraform {
  required_version= "~> 1.2.0"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "jonghwa"

    workspaces {
      prefix         = "ecs-"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.60.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"
  profile = local.config.tags.Environment
}

locals {
  config_file = "${terraform.workspace}/config.yaml"
  context     = yamldecode(file(local.config_file)).context
  config      = yamldecode(templatefile(local.config_file, local.context))
}