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

output "id" {
  description = "The ID of the API Destination (same as the ARN)."
  value       = module.api_destination.id
}

output "arn" {
  description = "The ARN of the API Destination."
  value       = module.api_destination.arn
}

output "name" {
  description = "The name of the API Destination."
  value       = module.api_destination.name
}

output "invocation_endpoint" {
  description = "The URL endpoint invoked as a target."
  value       = module.api_destination.invocation_endpoint
}

output "http_method" {
  description = "The HTTP method used for the invocation endpoint."
  value       = module.api_destination.http_method
}

output "invocation_rate_limit_per_second" {
  description = "The maximum invocations per second for this destination."
  value       = module.api_destination.invocation_rate_limit_per_second
}

output "connection_arn" {
  description = "The ARN of the EventBridge connection."
  value       = aws_cloudwatch_event_connection.connection.arn
}

output "event_rule_name" {
  description = "The name of the EventBridge rule that triggers the API destination."
  value       = aws_cloudwatch_event_rule.rule.name
}

output "dlq_url" {
  description = "URL of the dead-letter queue for failed event deliveries."
  value       = aws_sqs_queue.dlq.url
}
