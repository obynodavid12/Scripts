variable "aws_region" {
  default = "us-east-2"
}


variable "aws_api_gateway_rest_api_id" {
  default = "9b27lhpdeh"
}

variable "aws_api_gateway_stage_name" {
  default = "dev"
  type    = string
}