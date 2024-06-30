variable "aws_region" {
  description = "aws region to deploy the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "quickwit_index_name" {
  description = "Name of the quickwit index"
  type        = string
  default     = "quickwit-index"
}