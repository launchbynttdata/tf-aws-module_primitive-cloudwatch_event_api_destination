# Complete Example: EventBridge API Destination

This example creates an EventBridge connection and API destination, an IAM role for EventBridge to invoke the API destination, plus an event rule and target to trigger the API destination.

## Usage

```hcl
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "resource_names" {
  source   = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version  = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length

  region               = join("", split("-", data.aws_region.current.name))
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
  name   = "invoke-api-destination"
  role   = aws_iam_role.eventbridge_invoke_api_destination.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "events:InvokeApiDestination"
        Resource = "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:api-destination/*"
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

resource "aws_cloudwatch_event_target" "target" {
  rule           = aws_cloudwatch_event_rule.rule.name
  event_bus_name = "default"
  target_id      = "api-destination-target"
  arn            = module.api_destination.arn
  role_arn       = aws_iam_role.eventbridge_invoke_api_destination.arn
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| logical_product_family | Logical product family for resource naming. | `string` | n/a | yes |
| logical_product_service | Logical product service for resource naming. | `string` | n/a | yes |
| class_env | Class environment for resource naming (e.g., dev, prod). | `string` | n/a | yes |
| instance_env | Instance environment for resource naming (0-999). | `number` | n/a | yes |
| instance_resource | Instance resource for resource naming (0-100). | `number` | n/a | yes |
| resource_names_map | Map of resource types to naming configuration for the resource_name module. | `map(object({ name = string, max_length = number }))` | n/a | yes |
| connection_description | Description of the EventBridge connection. | `string` | `null` | no |
| connection_authorization_type | Authorization type for the EventBridge connection (API_KEY, BASIC, OAUTH_CLIENT_CREDENTIALS). | `string` | `"API_KEY"` | no |
| connection_api_key_name | API key header name for the connection. | `string` | n/a | yes |
| connection_api_key_value | API key value for the connection. Stored in AWS Secrets Manager. | `string` | n/a | yes |
| invocation_endpoint | URL endpoint to invoke as a target. Must use HTTPS. | `string` | n/a | yes |
| http_method | HTTP method for the invocation endpoint. | `string` | n/a | yes |
| description | Description of the API Destination. | `string` | `null` | no |
| invocation_rate_limit_per_second | Maximum invocations per second for the API destination. | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the API Destination (same as the ARN). |
| arn | The ARN of the API Destination. |
| name | The name of the API Destination. |
| invocation_endpoint | The URL endpoint invoked as a target. |
| http_method | The HTTP method used for the invocation endpoint. |
| invocation_rate_limit_per_second | The maximum invocations per second for this destination. |
| connection_arn | The ARN of the EventBridge connection. |
| event_rule_name | The name of the EventBridge rule that triggers the API destination. |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |
| <a name="module_api_destination"></a> [api\_destination](#module\_api\_destination) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_connection.connection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection) | resource |
| [aws_cloudwatch_event_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.eventbridge_invoke_api_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.eventbridge_invoke_api_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family for resource naming. | `string` | n/a | yes |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service for resource naming. | `string` | n/a | yes |
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Class environment for resource naming (e.g., dev, prod). | `string` | n/a | yes |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Instance environment for resource naming (0-999). | `number` | n/a | yes |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Instance resource for resource naming (0-100). | `number` | n/a | yes |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource types to naming configuration for the resource\_name module. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_connection_description"></a> [connection\_description](#input\_connection\_description) | Description of the EventBridge connection. | `string` | `null` | no |
| <a name="input_connection_authorization_type"></a> [connection\_authorization\_type](#input\_connection\_authorization\_type) | Authorization type for the EventBridge connection (API\_KEY, BASIC, OAUTH\_CLIENT\_CREDENTIALS). | `string` | `"API_KEY"` | no |
| <a name="input_connection_api_key_name"></a> [connection\_api\_key\_name](#input\_connection\_api\_key\_name) | API key header name for the connection. | `string` | n/a | yes |
| <a name="input_connection_api_key_value"></a> [connection\_api\_key\_value](#input\_connection\_api\_key\_value) | API key value for the connection. Stored in AWS Secrets Manager. | `string` | n/a | yes |
| <a name="input_invocation_endpoint"></a> [invocation\_endpoint](#input\_invocation\_endpoint) | URL endpoint to invoke as a target. Must use HTTPS. | `string` | n/a | yes |
| <a name="input_http_method"></a> [http\_method](#input\_http\_method) | HTTP method for the invocation endpoint. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the API Destination. | `string` | `null` | no |
| <a name="input_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#input\_invocation\_rate\_limit\_per\_second) | Maximum invocations per second for the API destination. | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the API Destination (same as the ARN). |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the API Destination. |
| <a name="output_name"></a> [name](#output\_name) | The name of the API Destination. |
| <a name="output_invocation_endpoint"></a> [invocation\_endpoint](#output\_invocation\_endpoint) | The URL endpoint invoked as a target. |
| <a name="output_http_method"></a> [http\_method](#output\_http\_method) | The HTTP method used for the invocation endpoint. |
| <a name="output_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#output\_invocation\_rate\_limit\_per\_second) | The maximum invocations per second for this destination. |
| <a name="output_connection_arn"></a> [connection\_arn](#output\_connection\_arn) | The ARN of the EventBridge connection. |
| <a name="output_event_rule_name"></a> [event\_rule\_name](#output\_event\_rule\_name) | The name of the EventBridge rule that triggers the API destination. |
<!-- END_TF_DOCS -->
