variable "aws_region" {
  description = "AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}


variable "name_prefix" {
  description = "Prefix applied to resource names."
  type        = string
  default     = "terraweek"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.micro"
}