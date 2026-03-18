logical_product_family  = "launch"
logical_product_service = "eventbridge"
class_env               = "dev"
instance_env            = 1
instance_resource       = 1

resource_names_map = {
  connection      = { name = "eventbridgeconnection1", max_length = 64 }
  api_destination = { name = "eventbridgeapidest1", max_length = 64 }
  event_rule      = { name = "eventbridgerule1", max_length = 64 }
  invoke_role     = { name = "invokeapidest1", max_length = 64 }
  dlq             = { name = "eventbridgedlq1", max_length = 80 }
}

connection_description        = "EventBridge connection for API destination example"
connection_authorization_type = "API_KEY"
connection_api_key_name       = "X-Api-Key"                         # pragma: allowlist secret
connection_api_key_value      = "example-api-key-value-for-testing" # pragma: allowlist secret

invocation_endpoint              = "https://httpbin.org/post"
http_method                      = "POST"
description                      = "Example API destination for EventBridge"
invocation_rate_limit_per_second = 20
