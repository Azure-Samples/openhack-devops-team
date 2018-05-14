package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	sw "github.com/Azure-Samples/openhack-devops/src/MobileAppServiceV2/TripService/tripsgo"
)

var (
	webServerPort    = flag.String("webServerPort", getEnv("WEB_PORT", "8080"), "web server port")
	webServerBaseURI = flag.String("webServerBaseURI", getEnv("SERVER_BASE_URI", "changeme"), "base portion of server uri")
)

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

func main() {

	log.Printf(fmt.Sprintf("%s%s", "Trips Service Server started on port ", *webServerPort))

	router := sw.NewRouter()

	log.Fatal(http.ListenAndServe(fmt.Sprintf("%s%s", ":", *webServerPort), router))
}
