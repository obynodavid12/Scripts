resource "aws_api_gateway_method_settings" "dev_settings" {
  rest_api_id = var.aws_api_gateway_rest_api_id
  stage_name  = var.aws_api_gateway_stage_name
  method_path = "*/*" #"path1/GET" or "${aws_api_gateway_resource.test.path_part}/${aws_api_gateway_method.test.http_method}"
  settings {
    logging_level = "INFO"   # Enables both Error and info logs
    #data_trace_enabled = false
    metrics_enabled = false
  }
}

