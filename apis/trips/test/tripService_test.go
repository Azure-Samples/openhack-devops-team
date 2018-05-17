package tripsgo

import (
	"encoding/json"
	"log"
	"testing"

	"github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"

	tripSvc "github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"
)

var apiTestList = []apiTestCase{
	{
		tag:              "t0 - healthcheck",
		method:           "GET",
		url:              "/api/healthcheck/trips",
		status:           200,
		expectedResponse: `{"message": "Trip Service Healthcheck","status": "Healthy"}`,
	},
	{
		tag:    "t1 - Get all trips",
		method: "GET",
		url:    "/api/trips",
		status: 200,
	},
	{
		tag:    "t2 - Get a nonexistent trip",
		method: "GET",
		url:    "/api/trips/99999",
		status: 404,
	},
	{
		tag:    "t3 - Create a Trip",
		method: "POST",
		url:    "/api/trips",
		body: `{
			"Name":"Trip CREATE TEST",
			"UserId":"GO_TEST",
			"RecordedTimeStamp": "2018-04-19T19:08:16.03Z",
			"EndTimeStamp": "2018-04-19T19:42:49.573Z",
			"Rating":95,
			"IsComplete":false,
			"HasSimulatedOBDData":true,
			"AverageSpeed":100,
			"FuelUsed":10.27193484,
			"HardStops":2,
			"HardAccelerations":4,
			"Distance":30.0275486,
			"Created":"2018-01-01T12:00:00Z",
			"UpdatedAt":"2001-01-01T12:00:00Z"
		}`,
		status: 200,
	},
	{
		tag:    "t4 - Update a trip",
		method: "PATCH",
		url:    "/api/trips/",
		body: `{
			"Name":"Trip UPDATE TEST",
			"UserId":"GO_TEST",
			"RecordedTimeStamp": "2018-04-19T19:08:16.03Z",
			"EndTimeStamp": "2018-04-19T19:42:49.573Z",
			"Rating":91005,
			"IsComplete":true,
			"HasSimulatedOBDData":true,
			"AverageSpeed":100,
			"FuelUsed":10.27193484,
			"HardStops":2,
			"HardAccelerations":4,
			"Distance":30.0275486,
			"Created":"2018-01-01T12:00:00Z",
			"UpdatedAt":"2001-01-01T12:00:00Z"
		}`, // set after create
		expectedResponse: "", // set after create
		status:           200,
	},
	{
		tag:    "t6 - Delete a Trip",
		method: "DELETE",
		url:    "/api/trips/",
		status: 200,
	},
}

func TestTrip(t *testing.T) {
	router := tripSvc.NewRouter()

	runAPITests(t, router, apiTestList[0:4])

	//setup update test (url, body, expected Response)
	apiTestList[4].url = apiTestList[4].url + TripFromStr(apiTestList[3].actualResponse).ID
	apiTestList[4].body = GetUpdateTrip(apiTestList[3].actualResponse, apiTestList[4].body)
	apiTestList[4].expectedResponse = apiTestList[4].body

	//setup delete test (url)
	apiTestList[5].url = apiTestList[5].url + TripFromStr(apiTestList[3].actualResponse).ID
	//run update test
	runAPITests(t, router, apiTestList[4:6])
}

func GetUpdateTrip(tripCreate string, tripUpdate string) string {
	tripC := TripFromStr(tripCreate)
	tripU := TripFromStr(tripUpdate)

	tripU.ID = tripC.ID

	serializedTripUpdate, _ := json.Marshal(tripU)

	return string(serializedTripUpdate)
}

func TripFromStr(tripStr string) tripsgo.Trip {
	trip := tripsgo.Trip{}

	tripsgo.LogToConsole(tripStr)

	errCreate := json.Unmarshal([]byte(tripStr), &trip)
	if errCreate != nil {
		log.Println("TripFromStr - Invalid trip string")
		log.Fatal(errCreate)
	}

	return trip
}
