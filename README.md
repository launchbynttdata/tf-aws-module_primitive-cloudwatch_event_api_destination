# Terraform AWS Module: EventBridge API Destination

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This Terraform module creates an [AWS EventBridge API Destination](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-api-destination.html). API Destinations allow you to send events to HTTP API endpoints as EventBridge targets, with configurable rate limiting and connection-based authorization.

## Documentation

- [Terraform AWS Provider: aws_cloudwatch_event_api_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_api_destination)
- [Amazon EventBridge API Destinations](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-api-destination.html)

## Pre-Commit Hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines pre-commit hooks for Terraform, Go, and common linting. The `detect-secrets-hook` prevents new secrets from being introduced into the baseline. See [pre-commit](https://pre-commit.com/) for installation.

Install the commit-msg hook for commitlint:

```
pre-commit install --hook-type commit-msg
```

## Usage

```hcl
module "api_destination" {
  source = "terraform.registry.launch.nttdata.com/module_primitive/cloudwatch_event_api_destination/aws"

  name                   = "my-api-destination"
  connection_arn         = aws_cloudwatch_event_connection.connection.arn
  invocation_endpoint    = "https://api.example.com/webhook"
  http_method            = "POST"
  description            = "API destination for webhook"
  invocation_rate_limit_per_second = 20
}
```

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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_api_destination.api_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_api_destination) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the API Destination. Must be unique within your account. Maximum 64 characters consisting of numbers, letters, dots, dashes, and underscores. | `string` | n/a | yes |
| <a name="input_connection_arn"></a> [connection\_arn](#input\_connection\_arn) | ARN of the EventBridge Connection to use for authorization with the API Destination. | `string` | n/a | yes |
| <a name="input_invocation_endpoint"></a> [invocation\_endpoint](#input\_invocation\_endpoint) | URL endpoint to invoke as a target. Must use HTTPS and can include '*' as path parameter wildcards. | `string` | n/a | yes |
| <a name="input_http_method"></a> [http\_method](#input\_http\_method) | HTTP method used for the invocation endpoint (e.g., GET, POST, PUT). | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the API Destination. Maximum 512 characters. | `string` | `null` | no |
| <a name="input_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#input\_invocation\_rate\_limit\_per\_second) | Maximum number of invocations per second allowed for this destination. Must be greater than 0. Defaults to 300. | `number` | `300` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the resource (same as the ARN). |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the event API Destination. |
| <a name="output_name"></a> [name](#output\_name) | The name of the API Destination. |
| <a name="output_invocation_endpoint"></a> [invocation\_endpoint](#output\_invocation\_endpoint) | The URL endpoint invoked as a target. |
| <a name="output_http_method"></a> [http\_method](#output\_http\_method) | The HTTP method used for the invocation endpoint. |
| <a name="output_invocation_rate_limit_per_second"></a> [invocation\_rate\_limit\_per\_second](#output\_invocation\_rate\_limit\_per\_second) | The maximum number of invocations per second for this destination. |
<!-- END_TF_DOCS -->

## Testing

1. Run `make configure` to set up the repository.
2. Configure AWS credentials (e.g., via `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_DEFAULT_REGION`).
3. Create `examples/complete/provider.tf` with your AWS provider configuration (delivered by Makefile when using repo sync).
4. Run `make check` to execute lint, validate, plan, and Terratest.
