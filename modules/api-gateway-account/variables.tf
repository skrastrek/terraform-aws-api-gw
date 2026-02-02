variable "role_name" {
  type    = string
  default = "api-gateway-cloudwatch-logs"
}

variable "role_permission_boundary_arn" {
  type    = string
  default = null
}

variable "tags" {
  type = map(string)
}
