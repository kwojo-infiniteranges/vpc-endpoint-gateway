variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "default_az" {
  type    = string
  default = "us-east-2a"
}

variable "primary_bucket_name" {
  type    = string
  default = "vpc-endpoint-demo-2022-12-14"
}

variable "aux_bucket_name" {
  type    = string
  default = "aux-vpc-endpoint-demo-2022-12-14"
}