terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "terraweek-2026"
      ManagedBy = "terraform"
      Day       = "03"
    }
  }
}

provider "aws" {
  alias  = "us_east2"
  region = "us-east-2"  # Hardcoded or map to a variable like var.aws_backup_region

  default_tags {
    tags = {
      Project   = "terraweek-2026"
      ManagedBy = "terraform"
      Day       = "03"
      Environment = "Disaster-Recovery" # Customized tag for the alias region
    }
  }
}