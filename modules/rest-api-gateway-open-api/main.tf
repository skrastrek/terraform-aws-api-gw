resource "aws_api_gateway_rest_api" "this" {
  name = var.name
  body = templatefile(var.open_api_template, var.open_api_template_vars)

  endpoint_configuration {
    types            = [var.endpoint_type]
    vpc_endpoint_ids = var.vpc_endpoint_ids
  }

  tags = var.tags
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = var.enable_metrics
    logging_level          = var.logging_level
    data_trace_enabled     = var.logging_data_trace_enabled
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = var.auto_redeploy ? {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.this.body,
      aws_api_gateway_rest_api_policy.this.policy
    ]))
  } : {}

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id           = aws_api_gateway_rest_api.this.id
  deployment_id         = aws_api_gateway_deployment.this.id
  stage_name            = var.stage_name
  cache_cluster_enabled = var.cache_cluster_enabled
  cache_cluster_size    = var.cache_cluster_size
  xray_tracing_enabled  = var.xray_tracing_enabled

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

  tags = var.tags
}

resource "aws_api_gateway_rest_api_policy" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  policy      = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  source_policy_documents = compact([
    data.aws_iam_policy_document.allow.json,
    try(data.aws_iam_policy_document.allow_source_vpc_endpoints[0].json, ""),
    try(data.aws_iam_policy_document.allow_vpc_source_ips[0].json, ""),
    try(data.aws_iam_policy_document.allow_source_ips[0].json, ""),
    try(data.aws_iam_policy_document.deny_source_ips[0].json, "")
  ])
}

data "aws_iam_policy_document" "allow" {
  statement {
    effect    = "Allow"
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "allow_source_vpc_endpoints" {
  count = var.resource_policy_allow_vpc_source_endpoint_ids == null ? 0 : 1

  statement {
    sid       = "AllowSourceVpcEndpoint"
    effect    = "Deny"
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = var.resource_policy_allow_vpc_source_endpoint_ids
    }
  }
}

data "aws_iam_policy_document" "allow_vpc_source_ips" {
  count = var.resource_policy_allow_vpc_source_ips == null ? 0 : 1

  statement {
    sid       = "AllowVpcSourceIp"
    effect    = "Deny"
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NotIpAddress"
      variable = "aws:VpcSourceIp"
      values   = var.resource_policy_allow_vpc_source_ips
    }
  }
}

data "aws_iam_policy_document" "allow_source_ips" {
  count = var.resource_policy_allow_source_ips == null ? 0 : 1

  statement {
    sid       = "AllowSourceIp"
    effect    = "Deny"
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NotIpAddress"
      variable = "aws:SourceIp"
      values   = var.resource_policy_allow_source_ips
    }
  }
}

data "aws_iam_policy_document" "deny_source_ips" {
  count = var.resource_policy_deny_source_ips == null ? 0 : 1

  statement {
    sid       = "DenySourceIp"
    effect    = "Deny"
    actions   = ["execute-api:Invoke"]
    resources = ["${aws_api_gateway_rest_api.this.execution_arn}/*/*/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = var.resource_policy_deny_source_ips
    }
  }
}

resource "aws_apigatewayv2_api_mapping" "this" {
  count = var.custom_domain_name != null ? 1 : 0

  api_id          = aws_api_gateway_rest_api.this.id
  stage           = aws_api_gateway_stage.this.stage_name
  domain_name     = var.custom_domain_name
  api_mapping_key = var.custom_domain_base_path_mapping
}
