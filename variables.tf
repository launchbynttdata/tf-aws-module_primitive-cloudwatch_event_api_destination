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

variable "name" {
  description = "The name of the API Destination. Must be unique within your account. Maximum 64 characters consisting of numbers, letters, dots, dashes, and underscores."
  type        = string

  validation {
    condition     = length(var.name) <= 64
    error_message = "Name must be 64 characters or fewer."
  }
}

variable "connection_arn" {
  description = "ARN of the EventBridge Connection to use for authorization with the API Destination."
  type        = string
}

variable "invocation_endpoint" {
  description = "URL endpoint to invoke as a target. Must use HTTPS and can include '*' as path parameter wildcards."
  type        = string

  validation {
    condition     = can(regex("^https://", var.invocation_endpoint))
    error_message = "Invocation endpoint must use HTTPS."
  }
}

variable "http_method" {
  description = "HTTP method used for the invocation endpoint (e.g., GET, POST, PUT)."
  type        = string

  validation {
    condition     = contains(["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"], upper(var.http_method))
    error_message = "HTTP method must be one of: DELETE, GET, HEAD, OPTIONS, PATCH, POST, PUT."
  }
}

variable "description" {
  description = "Description of the API Destination. Maximum 512 characters."
  type        = string
  default     = null

  validation {
    condition     = var.description == null ? true : (length(var.description) <= 512)
    error_message = "Description must be 512 characters or fewer."
  }
}

variable "invocation_rate_limit_per_second" {
  description = "Maximum number of invocations per second allowed for this destination. Must be greater than 0. Defaults to 300."
  type        = number
  default     = 300

  validation {
    condition     = var.invocation_rate_limit_per_second > 0
    error_message = "Invocation rate limit per second must be greater than 0."
  }
}
