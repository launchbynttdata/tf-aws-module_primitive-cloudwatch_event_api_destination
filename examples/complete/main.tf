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

data "aws_region" "current" {}

module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length

  region                = join("", split("-", data.aws_region.current.name))
  use_azure_region_abbr = false
}

resource "aws_cloudwatch_event_connection" "connection" {
  name               = module.resource_names["connection"].standard
  description        = var.connection_description
  authorization_type = var.connection_authorization_type

  auth_parameters {
    api_key {
      key   = var.connection_api_key_name
      value = var.connection_api_key_value
    }
  }
}

module "api_destination" {
  source = "../.."

  name                             = module.resource_names["api_destination"].standard
  connection_arn                   = aws_cloudwatch_event_connection.connection.arn
  invocation_endpoint              = var.invocation_endpoint
  http_method                      = var.http_method
  description                      = var.description
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
}

resource "aws_iam_role" "eventbridge_invoke_api_destination" {
  name = module.resource_names["invoke_role"].standard

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke_api_destination" {
  name = "invoke-api-destination"
  role = aws_iam_role.eventbridge_invoke_api_destination.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "events:InvokeApiDestination"
        Resource = module.api_destination.arn
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "rule" {
  name           = module.resource_names["event_rule"].standard
  description    = "Rule to trigger API destination for testing"
  event_bus_name = "default"
  event_pattern  = jsonencode({ "source" = ["test.api-destination"] })
}

resource "aws_sqs_queue" "dlq" {
  name              = module.resource_names["dlq"].standard
  kms_master_key_id = "alias/aws/sqs"
}

resource "aws_sqs_queue_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "events.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.dlq.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.rule.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_target" "target" {
  rule           = aws_cloudwatch_event_rule.rule.name
  event_bus_name = "default"
  target_id      = "api-destination-target"
  arn            = module.api_destination.arn
  role_arn       = aws_iam_role.eventbridge_invoke_api_destination.arn

  dead_letter_config {
    arn = aws_sqs_queue.dlq.arn
  }
}
