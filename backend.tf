terraform {
  required_version = ">= 1.0.0"
  backend "s3" {
    bucket  = "alb-project-bucket1234"                  # Replace with your unique S3 bucket name
    key     = "hackthon/to/my/statefile/terraform.tfstate" # Path inside the bucket to store the state
    region  = "us-east-1"                              # Replace with your desired AWS region
    encrypt = true                                     # Enable encryption of the state file
    acl     = "private"                                # Ensure the bucket is private
  }
}
