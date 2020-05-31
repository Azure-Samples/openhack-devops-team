package tripsgo

import (
	"io/ioutil"
	"os"
	"testing"
)

var swaggerRouteTests = []APITestCase{
	{
		Tag:    "swaggerService",
		Method: "GET",
		URL:    "/api/json/swagger.json",
		Status: 200,
	},
}

func TestSwaggerServiceUnit(t *testing.T) {
	router := NewRouter()
	os.Setenv("SWAGGER_JSON_PATH", "../api/swagger.json")
	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}
	RunAPITests(t, router, swaggerRouteTests[0:1])

}
