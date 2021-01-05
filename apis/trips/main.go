package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"

	sw "github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"
)

var (
	webServerPort    = flag.String("webServerPort", getEnv("WEB_PORT", "8080"), "web server port")
	webServerBaseURI = flag.String("webServerBaseURI", getEnv("WEB_SERVER_BASE_URI", "changeme"), "base portion of server uri")
)

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func main() {

	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		sw.InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		sw.InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}

	sw.Info.Println(fmt.Sprintf("%s%s", "Trips Service Server started on port ", *webServerPort))

	router := sw.NewRouter()

	sw.Fatal.Println(http.ListenAndServe(fmt.Sprintf("%s%s", ":", *webServerPort), router))
}
