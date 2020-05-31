package tripsgo

import (
	"io/ioutil"
	"os"
	"testing"
)

var versionRouteTests = []APITestCase{
	{
		Tag:              "versionService",
		Method:           "GET",
		URL:              "/api/version/trips",
		Status:           200,
		ExpectedResponse: `test123`,
	},
}

func TestVersionServiceUnit(t *testing.T) {
	router := NewRouter()
	os.Setenv("APP_VERSION", "test123")
	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}
	RunAPITestsPlainText(t, router, versionRouteTests[0:1])

}
