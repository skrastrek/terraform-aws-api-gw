resource "aws_apigatewayv2_authorizer" "this" {
  count = var.authorizer != null && var.authorizer.authorizer_type != "AWS_IAM" ? 1 : 0

  api_id           = aws_apigatewayv2_api.this.id
  name             = "${var.name}-authorizer"
  authorizer_type  = var.authorizer.authorizer_type
  identity_sources = var.authorizer.identity_sources

  authorizer_uri                    = var.authorizer.authorizer_type == "REQUEST" ? var.authorizer.authorizer_uri : null
  authorizer_payload_format_version = var.authorizer.authorizer_type == "REQUEST" ? var.authorizer.authorizer_payload_format_version : null
  authorizer_result_ttl_in_seconds  = var.authorizer.authorizer_type == "REQUEST" ? var.authorizer.authorizer_result_ttl_in_seconds : null
  enable_simple_responses           = var.authorizer.authorizer_type == "REQUEST" ? var.authorizer.enable_simple_responses : null

  dynamic "jwt_configuration" {
    for_each = var.authorizer.authorizer_type == "JWT" ? [var.authorizer.jwt_configuration] : []
    content {
      audience = jwt_configuration.value.audience
      issuer   = jwt_configuration.value.issuer
    }
  }
}