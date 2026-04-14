resource "aws_api_gateway_authorizer" "this" {
  count = var.authorizer != null && var.authorizer.type != "AWS_IAM" ? 1 : 0

  rest_api_id                      = aws_api_gateway_rest_api.this.id
  name                             = "${var.name}-authorizer"
  type                             = var.authorizer.type
  authorizer_uri                   = var.authorizer.authorizer_uri
  identity_source                  = var.authorizer.identity_source
  authorizer_result_ttl_in_seconds = var.authorizer.result_ttl_in_seconds
  identity_validation_expression   = var.authorizer.identity_validation_expression
  provider_arns                    = var.authorizer.provider_arns
}