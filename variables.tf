variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "cloudtrail_s3_bucket" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "alert_email" {
  description = "Email to receive SNS alerts"
  type        = string
}
