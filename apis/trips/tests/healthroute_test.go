package tests

import (
	"io/ioutil"
	"os"
	"testing"

	tripSvc "github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"
)

var healthRouteTests = []tripSvc.APITestCase{
	{
		Tag:              "t0 - healthcheck",
		Method:           "GET",
		URL:              "/api/healthcheck/trips",
		Status:           200,
		ExpectedResponse: `{"message": "Trip Service Healthcheck","status": "Healthy"}`,
	},
}

func TestHealthRoute(t *testing.T) {
	router := tripSvc.NewRouter()
	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		tripSvc.InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		tripSvc.InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}
	tripSvc.RunAPITests(t, router, healthRouteTests[0:1])

}
