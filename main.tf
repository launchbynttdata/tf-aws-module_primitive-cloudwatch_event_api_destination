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

resource "aws_cloudwatch_event_api_destination" "api_destination" {
  name                             = var.name
  connection_arn                   = var.connection_arn
  invocation_endpoint              = var.invocation_endpoint
  http_method                      = var.http_method
  description                      = var.description
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
}
