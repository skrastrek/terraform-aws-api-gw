resource "aws_apigatewayv2_api" "this" {
  name        = var.name
  description = var.description

  protocol_type = var.protocol_type

  body = templatefile(var.open_api_template, var.open_api_template_vars)

  dynamic "cors_configuration" {
    for_each = var.cors_configuration != null ? [var.cors_configuration] : []
    content {
      allow_credentials = cors_configuration.value.allow_credentials
      allow_headers     = cors_configuration.value.allow_headers
      allow_methods     = cors_configuration.value.allow_methods
      allow_origins     = cors_configuration.value.allow_origins
      expose_headers    = cors_configuration.value.expose_headers
      max_age           = cors_configuration.value.max_age
    }
  }

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.this.id

  name        = "$default"
  auto_deploy = var.auto_deploy

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.access_logs.arn
    format = var.access_log_format != null ? var.access_log_format : jsonencode({
      "ip" : "$context.identity.sourceIp"
      "sub" : "$context.authorizer.sub"
      "requestId" : "$context.requestId"
      "requestTime" : "$context.requestTime"
      "requestProtocol" : "$context.protocol"
      "requestMethod" : "$context.httpMethod"
      "requestPath" : "$context.path"
      "responseStatus" : "$context.status"
      "responseLatency" : "$context.responseLatency"
      "responseLength" : "$context.responseLength"
    })
  }

  default_route_settings {
    throttling_rate_limit    = var.throttle_rate_limit
    throttling_burst_limit   = var.throttle_burst_limit
    detailed_metrics_enabled = var.detailed_metrics_enabled
    logging_level            = var.protocol_type == "WEBSOCKET" ? var.logging_level : null
    data_trace_enabled       = var.protocol_type == "WEBSOCKET" ? var.logging_data_trace_enabled : null
  }

  tags = var.tags
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.custom_domain_name != null ? 1 : 0

  api_id          = aws_apigatewayv2_api.this.id
  stage           = aws_apigatewayv2_stage.default.name
  domain_name     = var.custom_domain_name
  api_mapping_key = var.custom_domain_base_path_mapping
}
