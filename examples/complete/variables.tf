// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

variable "logical_product_family" {
  description = "Logical product family for resource naming."
  type        = string
}

variable "logical_product_service" {
  description = "Logical product service for resource naming."
  type        = string
}

variable "class_env" {
  description = "Class environment for resource naming (e.g., dev, prod)."
  type        = string
}

variable "instance_env" {
  description = "Instance environment for resource naming (0-999)."
  type        = number
}

variable "instance_resource" {
  description = "Instance resource for resource naming (0-100)."
  type        = number
}

variable "resource_names_map" {
  description = "Map of resource types to naming configuration for the resource_name module."
  type = map(object({
    name       = string
    max_length = number
  }))
}

variable "connection_description" {
  description = "Description of the EventBridge connection."
  type        = string
  default     = null
}

variable "connection_authorization_type" {
  description = "Authorization type for the EventBridge connection (API_KEY, BASIC, OAUTH_CLIENT_CREDENTIALS)."
  type        = string
  default     = "API_KEY"
}

variable "connection_api_key_name" {
  description = "API key header name for the connection."
  type        = string
}

variable "connection_api_key_value" {
  description = "API key value for the connection. Stored in AWS Secrets Manager."
  type        = string
  sensitive   = true
}

variable "invocation_endpoint" {
  description = "URL endpoint to invoke as a target. Must use HTTPS."
  type        = string
}

variable "http_method" {
  description = "HTTP method for the invocation endpoint."
  type        = string
}

variable "description" {
  description = "Description of the API Destination."
  type        = string
  default     = null
}

variable "invocation_rate_limit_per_second" {
  description = "Maximum invocations per second for the API destination."
  type        = number
  default     = 300
}
