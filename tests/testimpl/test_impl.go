package testimpl

import (
	"context"
	"os"
	"regexp"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/eventbridge"
	eventbridgetypes "github.com/aws/aws-sdk-go-v2/service/eventbridge/types"
	"github.com/aws/aws-sdk-go-v2/service/sqs"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func getRegion(t *testing.T, _ *terraform.Options) string {
	region := os.Getenv("AWS_DEFAULT_REGION")
	if region == "" {
		region = os.Getenv("AWS_REGION")
	}
	if region == "" {
		region = "us-east-1"
	}
	return region
}

func TestComposableComplete(t *testing.T, ctx types.TestContext) {
	t.Run("VerifyTerraformOutputs", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		arn := terraform.Output(t, opts, "arn")
		name := terraform.Output(t, opts, "name")
		invocationEndpoint := terraform.Output(t, opts, "invocation_endpoint")
		httpMethod := terraform.Output(t, opts, "http_method")
		invocationRateLimit := terraform.Output(t, opts, "invocation_rate_limit_per_second")

		assert.Contains(t, arn, "arn:aws:events:", "ARN should be a valid EventBridge API destination ARN")
		assert.Regexp(t, regexp.MustCompile(`^[a-zA-Z0-9.-]+$`), name, "Name should match EventBridge resource naming")
		assert.Equal(t, "https://httpbin.org/post", invocationEndpoint, "Invocation endpoint should match test.tfvars")
		assert.Equal(t, "POST", httpMethod, "HTTP method should match test.tfvars")
		assert.Equal(t, "20", invocationRateLimit, "Invocation rate limit should match test.tfvars")
	})

	t.Run("VerifyApiDestinationViaAWS", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		arn := terraform.Output(t, opts, "arn")
		name := terraform.Output(t, opts, "name")
		region := getRegion(t, opts)

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		client := eventbridge.NewFromConfig(cfg)
		result, err := client.DescribeApiDestination(context.Background(), &eventbridge.DescribeApiDestinationInput{
			Name: aws.String(name),
		})
		require.NoError(t, err)
		require.NotNil(t, result)

		assert.Equal(t, arn, aws.ToString(result.ApiDestinationArn), "ARN should match Terraform output")
		assert.Equal(t, name, aws.ToString(result.Name), "API destination name should match")
		assert.Equal(t, "https://httpbin.org/post", aws.ToString(result.InvocationEndpoint), "Invocation endpoint should match")
		assert.Equal(t, "POST", string(result.HttpMethod), "HTTP method should match")
		assert.Equal(t, int32(20), aws.ToInt32(result.InvocationRateLimitPerSecond), "Invocation rate limit should match")
		assert.Equal(t, "Example API destination for EventBridge", aws.ToString(result.Description), "Description should match")
	})

	t.Run("ExerciseApiDestinationWithPutEvents", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		region := getRegion(t, opts)
		dlqURL := terraform.Output(t, opts, "dlq_url")

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		ebClient := eventbridge.NewFromConfig(cfg)
		_, err = ebClient.PutEvents(context.Background(), &eventbridge.PutEventsInput{
			Entries: []eventbridgetypes.PutEventsRequestEntry{
				{
					Source:       aws.String("test.api-destination"),
					DetailType:   aws.String("Test"),
					Detail:       aws.String(`{"test": "value"}`),
					EventBusName: aws.String("default"),
				},
			},
		})
		require.NoError(t, err)

		time.Sleep(30 * time.Second)

		sqsClient := sqs.NewFromConfig(cfg)
		receiveOut, err := sqsClient.ReceiveMessage(context.Background(), &sqs.ReceiveMessageInput{
			QueueUrl:            aws.String(dlqURL),
			MaxNumberOfMessages: 10,
			WaitTimeSeconds:     1,
		})
		require.NoError(t, err)
		assert.Empty(t, receiveOut.Messages, "DLQ should be empty; failed deliveries would indicate broken target wiring, permissions, or connection auth")
	})
}

func TestComposableCompleteReadonly(t *testing.T, ctx types.TestContext) {
	t.Run("VerifyTerraformOutputsReadonly", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		arn := terraform.Output(t, opts, "arn")
		name := terraform.Output(t, opts, "name")

		assert.Contains(t, arn, "arn:aws:events:", "ARN should be a valid EventBridge API destination ARN")
		assert.Regexp(t, regexp.MustCompile(`^[a-zA-Z0-9.-]+$`), name, "Name should match EventBridge resource naming")
	})

	t.Run("VerifyApiDestinationExistsViaAWS", func(t *testing.T) {
		opts := ctx.TerratestTerraformOptions()
		arn := terraform.Output(t, opts, "arn")
		name := terraform.Output(t, opts, "name")
		region := getRegion(t, opts)

		cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
		require.NoError(t, err)

		client := eventbridge.NewFromConfig(cfg)
		result, err := client.DescribeApiDestination(context.Background(), &eventbridge.DescribeApiDestinationInput{
			Name: aws.String(name),
		})
		require.NoError(t, err)
		require.NotNil(t, result)

		assert.Equal(t, name, aws.ToString(result.Name), "API destination name should match")
		assert.Equal(t, arn, aws.ToString(result.ApiDestinationArn), "ARN should match API response")
		assert.Equal(t, "https://httpbin.org/post", aws.ToString(result.InvocationEndpoint), "Invocation endpoint should match")
		assert.Equal(t, "POST", string(result.HttpMethod), "HTTP method should match")
		assert.Equal(t, int32(20), aws.ToInt32(result.InvocationRateLimitPerSecond), "Invocation rate limit should match")
	})
}
