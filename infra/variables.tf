# Variables for reusability
variable "region" {
  default = "us-east-2"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "resource_name" {
  description = "Name for the cloud resources"
  default     = "devsecopspy"
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-09da212cf18033880"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  default     = "devsecopspy"
}
