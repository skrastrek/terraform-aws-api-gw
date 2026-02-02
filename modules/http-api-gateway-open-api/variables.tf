variable "name" {
  type = string
}

variable "description" {
  type    = string
  default = ""
}

variable "protocol_type" {
  type    = string
  default = "HTTP"
}

variable "cors_configuration" {
  type = object({
    allow_credentials = optional(bool)
    allow_headers     = optional(set(string))
    allow_methods     = optional(set(string))
    allow_origins     = optional(set(string))
    expose_headers    = optional(set(string))
    max_age           = optional(number)
  })
  default = null
}

variable "open_api_template" {
  type = string
}

variable "open_api_template_vars" {
  type = map(any)
}

variable "access_log_retention_in_days" {
  type    = number
  default = 180
}

variable "access_log_format" {
  type    = string
  default = null
}

variable "logging_level" {
  type    = string
  default = "INFO"
}

variable "logging_data_trace_enabled" {
  type        = bool
  default     = false
  description = "Supported only for WebSocket APIs"
}

variable "detailed_metrics_enabled" {
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

variable "custom_domain_name" {
  type    = string
  default = null
}

variable "custom_domain_base_path_mapping" {
  type        = string
  default     = null
  description = "Path segment that must be prepended to the path when accessing the API. If null, the API is exposed at the root of the given domain."
}

variable "auto_deploy" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)
}
