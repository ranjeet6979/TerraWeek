variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "instances" {
  type = map(object({
    instance_type = string
  }))
  default = {
    "web-prod" = { instance_type = "t3.micro" }
    "web-dev"  = { instance_type = "t3.micro" }
  }
}

variable "name_prefix" {
  description = "Prefix applied to resource names."
  type        = string
  default     = "terraweek"
}
