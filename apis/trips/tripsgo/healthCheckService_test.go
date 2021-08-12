package tripsgo

import (
	"io/ioutil"
	"os"
	"testing"
)

var healthRouteTests = []APITestCase{
	{
		Tag:              "t0 - healthcheck",
		Method:           "GET",
		URL:              "/api/healthcheck/trips",
		Status:           200,
		ExpectedResponse: `{"message": "Trip Service Healthcheck","status": "Healthy"}`,
	},
}

func TestHealthRouteUnit(t *testing.T) {
	router := NewRouter()
	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}
	RunAPITests(t, router, healthRouteTests[0:1])

}
