package tripsgo

import (
	"io/ioutil"
	"os"
	"testing"

	tripSvc "github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"
)

var testHealthRoute = []apiTestCase{
	{
		tag:              "t0 - healthcheck",
		method:           "GET",
		url:              "/api/healthcheck/trips",
		status:           200,
		expectedResponse: `{"message": "Trip Service Healthcheck","status": "Healthy"}`,
	},
}

func TestHealth(t *testing.T) {
	router := tripSvc.NewRouter()
	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		tripSvc.InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		tripSvc.InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}
	RunAPITests(t, router, testHealthRoute[0:1])

}
