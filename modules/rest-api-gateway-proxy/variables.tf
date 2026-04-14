variable "name" {
  type = string
}

variable "integration_uri" {
  type        = string
  description = "URI of the backend. Lambda invocation ARN for AWS_PROXY, or HTTP URL for HTTP_PROXY."
}

variable "integration_type" {
  type        = string
  default     = "AWS_PROXY"
  description = "Integration type. AWS_PROXY for Lambda, HTTP_PROXY for HTTP backends."
}

variable "integration_http_method" {
  type        = string
  default     = "POST"
  description = "HTTP method used for the integration. Must be POST for AWS_PROXY (Lambda)."
}

variable "connection_type" {
  type        = string
  default     = "INTERNET"
  description = "Integration connection type. INTERNET or VPC_LINK. Only applies to HTTP_PROXY."
}

variable "connection_id" {
  type        = string
  default     = null
  description = "VPC Link ID. Required when connection_type is VPC_LINK."
}

variable "endpoint_type" {
  type    = string
  default = "REGIONAL"
}

variable "vpc_endpoint_ids" {
  type        = list(string)
  default     = null
  description = "VPC endpoints for private API gateway"
}

variable "access_log_retention_in_days" {
  type    = number
  default = 180
}

variable "access_log_format" {
  type    = string
  default = null
}

variable "execution_log_retention_in_days" {
  type    = number
  default = 180
}

variable "resource_policy_allow_vpc_source_endpoint_ids" {
  description = "Allow access from VPC source endpoint IDs."
  type        = list(string)
  default     = null
}

variable "resource_policy_allow_vpc_source_ips" {
  description = "Allow access from private IP address ranges."
  type        = list(string)
  default     = null
}

variable "resource_policy_allow_source_ips" {
  description = "Allow access from public IP address ranges."
  type        = list(string)
  default     = null
}

variable "resource_policy_deny_source_ips" {
  description = "Deny access from public IP address ranges."
  type        = list(string)
  default     = null
}

variable "xray_tracing_enabled" {
  type    = bool
  default = false
}

variable "stage_name" {
  type    = string
  default = "default"
}

variable "cache_cluster_enabled" {
  type    = bool
  default = false
}

variable "cache_cluster_size" {
  type    = number
  default = 0.5
}

variable "logging_level" {
  type    = string
  default = "INFO"
}

variable "logging_data_trace_enabled" {
  type        = bool
  default     = false
  description = "Enable logging of full request/response data."
}

variable "enable_metrics" {
  type    = bool
  default = true
}

variable "throttle_burst_limit" {
  type    = number
  default = 10
}

variable "throttle_rate_limit" {
  type    = number
  default = 10
}

variable "waf_web_acl_arn" {
  type    = string
  default = null
}

variable "custom_domain_name" {
  type    = string
  default = null
}

variable "custom_domain_base_path_mapping" {
  type        = string
  default     = null
  description = "Path segment that must be prepended to the path when accessing the API. If null, the API is exposed at the root of the given domain."
}

variable "authorizer" {
  type = object({
    type                           = string # TOKEN, REQUEST, COGNITO_USER_POOLS, or AWS_IAM
    authorizer_uri                 = optional(string) # Lambda invoke ARN, for TOKEN/REQUEST types
    identity_source                = optional(string, "method.request.header.Authorization")
    result_ttl_in_seconds          = optional(number, 300)
    identity_validation_expression = optional(string) # TOKEN type only
    provider_arns                  = optional(list(string)) # COGNITO_USER_POOLS type only
  })
  default = null
}

variable "auto_redeploy" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
}