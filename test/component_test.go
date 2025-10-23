package test

import (
	"fmt"
	"os"
	"strings"
	"testing"

	helper "github.com/cloudposse/test-helpers/pkg/atmos/component-helper"
	awsTerratest "github.com/gruntwork-io/terratest/modules/aws"
	"github.com/cloudposse/test-helpers/pkg/atmos"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/assert"
)

type ComponentSuite struct {
	helper.TestSuite

	datadogAPIKey string // Datadog API key
	datadogAppKey string // Datadog App key
	datadogHost   string // Datadog host
	randomID      string
	awsRegion     string
}

func (s *ComponentSuite) TestBasic() {
	const component = "datadog-logs-archive/basic"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	randomID := strings.ToLower(random.UniqueId())

	// Store the Datadog API key in SSM for the duration of the test.
	apiKeyPath := fmt.Sprintf("/datadog/%s/datadog_api_key", randomID)
	awsTerratest.PutParameter(s.T(), s.awsRegion, apiKeyPath, "Datadog API Key", s.datadogAPIKey)

	// Store the Datadog App key in SSM for the duration of the test.
	appKeyPath := fmt.Sprintf("/datadog/%s/datadog_app_key", randomID)
	awsTerratest.PutParameter(s.T(), s.awsRegion, appKeyPath, "Datadog App Key", s.datadogAppKey)

	defer func() {
		if !s.Config.SkipDestroyComponent {
			awsTerratest.DeleteParameter(s.T(), awsRegion, apiKeyPath)
			awsTerratest.DeleteParameter(s.T(), awsRegion, appKeyPath)
		}
	}()

	defer s.DestroyAtmosComponent(s.T(), component, stack, nil)
	options, _ := s.DeployAtmosComponent(s.T(), component, stack, nil)
	assert.NotNil(s.T(), options)

	cloudtrailBucketName := atmos.Output(s.T(), options, "cloudtrail_bucket_id")

	defer func() {
		if !s.Config.SkipDestroyComponent {
			atmos.DestroyE(s.T(), options)
			aws.EmptyS3Bucket(s.T(), awsRegion, cloudtrailBucketName)
		}
	}()

	s.DriftTest(component, stack, nil)
}

func (s *ComponentSuite) TestEnabledFlag() {
	const component = "datadog-logs-archive/disabled"
	const stack = "default-test"
	const awsRegion = "us-east-2"

	randomID := strings.ToLower(random.UniqueId())

	// Store the Datadog API key in SSM for the duration of the test.
	apiKeyPath := fmt.Sprintf("/datadog/%s/datadog_api_key", randomID)
	awsTerratest.PutParameter(s.T(), s.awsRegion, apiKeyPath, "Datadog API Key", s.datadogAPIKey)

	// Store the Datadog App key in SSM for the duration of the test.
	appKeyPath := fmt.Sprintf("/datadog/%s/datadog_app_key", randomID)
	awsTerratest.PutParameter(s.T(), s.awsRegion, appKeyPath, "Datadog App Key", s.datadogAppKey)

	defer func() {
		awsTerratest.DeleteParameter(s.T(), awsRegion, apiKeyPath)
		awsTerratest.DeleteParameter(s.T(), awsRegion, appKeyPath)
	}()

	s.VerifyEnabledFlag(component, stack, nil)
}

func (s *ComponentSuite) SetupSuite() {
	s.InitConfig()
	s.Config.ComponentDestDir = "components/terraform/datadog-logs-archive"

	// Store the Datadog API key in SSM for the duration of the test.
	// Add the key to /datadog/<RANDOMID>/datadog_api_key to avoid
	// conflicts during parallel tests and remove the key after the test.
	s.datadogAPIKey = os.Getenv("DD_API_KEY")
	if s.datadogAPIKey == "" {
		s.T().Fatal("DD_API_KEY environment variable must be set")
	}

	// Store the Datadog App key in SSM for the duration of the test.
	// Add the key to /datadog/<RANDOMID>/datadog_app_key to avoid
	// conflicts during parallel tests and remove the key after the test.
	s.datadogAppKey = os.Getenv("DD_APP_KEY")
	if s.datadogAppKey == "" {
		s.T().Fatal("DD_APP_KEY environment variable must be set")
	}

	s.randomID = strings.ToLower(random.UniqueId())
	s.awsRegion = "us-east-2"
	s.datadogHost = "us5.datadoghq.com"

	if !s.Config.SkipDeployDependencies {
		apiKeyPath := fmt.Sprintf("/datadog/%s/datadog_api_key", s.randomID)
		awsTerratest.PutParameter(s.T(), s.awsRegion, apiKeyPath, "Datadog API Key", s.datadogAPIKey)

		appKeyPath := fmt.Sprintf("/datadog/%s/datadog_app_key", s.randomID)
		awsTerratest.PutParameter(s.T(), s.awsRegion, appKeyPath, "Datadog App Key", s.datadogAppKey)

		inputs := map[string]any{
			"datadog_site_url": s.datadogHost,
			"datadog_secrets_source_store_account_region": s.awsRegion,
			"datadog_secrets_source_store_account_stage":  "test",
			"datadog_secrets_source_store_account_tenant": "default",
			"datadog_api_secret_key":                      s.randomID,
			"datadog_app_secret_key":                      s.randomID,
		}
		s.AddDependency(s.T(), "datadog-configuration", "default-test", &inputs)
		s.AddDependency(s.T(), "datadog-integration", "default-test", &map[string]any{})
	}

	s.TestSuite.SetupSuite()
}

func (s *ComponentSuite) TearDownSuite() {
	s.TestSuite.TearDownSuite()
	if !s.Config.SkipDestroyDependencies {
		apiKeyPath := fmt.Sprintf("/datadog/%s/datadog_api_key", s.randomID)
		awsTerratest.DeleteParameter(s.T(), s.awsRegion, apiKeyPath)

		appKeyPath := fmt.Sprintf("/datadog/%s/datadog_app_key", s.randomID)
		awsTerratest.DeleteParameter(s.T(), s.awsRegion, appKeyPath)
	}
}

func TestRunSuite(t *testing.T) {
	suite := new(ComponentSuite)

	helper.Run(t, suite)
}
