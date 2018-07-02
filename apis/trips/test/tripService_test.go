package tripsgo

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"

	tripSvc "github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"
)

var tripID string

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
			"CreatedAt":"2018-01-01T12:00:00Z",
			"UpdatedAt":"2001-01-01T12:00:00Z"
		}`,
		status: 200,
	},
	{
		tag:    "t4 - Update a trip",
		method: "PATCH",
		url:    "/api/trips/{tripID}",
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
			"CreatedAt":"2018-01-01T12:00:00Z",
			"UpdatedAt":"2001-01-01T12:00:00Z"
		}`,
		status: 200,
	},
	{
		tag:    "t5 - Create Trip Point",
		method: "POST",
		url:    "/api/trips/{tripID}/trippoints",
		body: `{
			"TripId": "{tripID}",
			"Latitude": 47.67598,
			"Longitude": -122.10612,
			"Speed": -255,
			"RecordedTimeStamp": "2018-05-24T10:00:15.003Z",
			"Sequence": 2,
			"RPM": -255,
			"ShortTermFuelBank": -255,
			"LongTermFuelBank": -255,
			"ThrottlePosition": -255,
			"RelativeThrottlePosition": -255,
			"Runtime": -255,
			"DistanceWithMalfunctionLight": -255,
			"EngineLoad": -255,
			"EngineFuelRate": -255,
			"CreatedAt": "0001-01-01T00:00:00Z",
			"UpdatedAt": "0001-01-01T00:00:00Z"
			}`,
		status: 200,
	},
	{
		tag:    "t6 - Update Trip Point",
		method: "PATCH",
		url:    "/api/trips/{tripID}/trippoints/{tripPointID}",
		body: `{
			"Id": "{tripPointID}",
			"TripId": "{tripID}",
			"Latitude": 47.67598,
			"Longitude": -122.10612,
			"Speed": -255,
			"RecordedTimeStamp": "2018-05-24T10:00:15.003Z",
			"Sequence": 2,
			"RPM": -255,
			"ShortTermFuelBank": -255,
			"LongTermFuelBank": -255,
			"ThrottlePosition": -255,
			"RelativeThrottlePosition": -255,
			"Runtime": -255,
			"DistanceWithMalfunctionLight": -255,
			"EngineLoad": -255,
			"EngineFuelRate": -255,
			"Created": "0001-01-01T00:00:00Z",
			"UpdatedAt": "0001-01-01T00:00:00Z"
			}`,
		expectedResponse: "",
		status:           200,
	},
	{
		tag:    "t7 - Read Trip Points for Trip",
		method: "GET",
		url:    "/api/trips/{tripID}/trippoints",
		status: 200,
	},
	{
		tag:    "t8 - Read Trip Points By Trip Point ID",
		method: "GET",
		url:    "/api/trips/{tripID}/trippoints/{tripPointID}",
		status: 200,
	},
	{
		tag:    "t9 - Delete Trip Point",
		method: "DELETE",
		url:    "/api/trips/{tripID}/trippoints/{tripPointID}",
		status: 200,
	},
	{
		tag:    "t10 - Delete a Trip",
		method: "DELETE",
		url:    "/api/trips/{tripID}",
		status: 200,
	},
}

func TestTrip(t *testing.T) {
	router := tripSvc.NewRouter()
	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		tripSvc.InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		tripSvc.InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}
	runAPITests(t, router, apiTestList[0:4])

	// setup update trip test (url, body, expected Response)
	apiTestList[4].url = strings.Replace(apiTestList[4].url, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)
	apiTestList[4].body = GetUpdateTrip(apiTestList[3].actualResponse, apiTestList[4].body)
	apiTestList[4].expectedResponse = apiTestList[4].body

	// setup create trip point test
	apiTestList[5].url = strings.Replace(apiTestList[5].url, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)
	apiTestList[5].body = strings.Replace(apiTestList[5].body, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)

	// run update trip and create trip point tests
	runAPITests(t, router, apiTestList[4:6])

	// setup update trip point test
	apiTestList[6].url = strings.Replace(apiTestList[6].url, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)
	apiTestList[6].url = strings.Replace(apiTestList[6].url, "{tripPointID}", TripPointFromStr(apiTestList[5].actualResponse).ID, 1)
	apiTestList[6].body = GetUpdateTripPoint(apiTestList[5].actualResponse, apiTestList[6].body)
	//apiTestList[6].expectedResponse = apiTestList[6].body

	// setup read trip points for trip test
	apiTestList[7].url = strings.Replace(apiTestList[7].url, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)

	// setup ready trip points by trip point id test
	apiTestList[8].url = strings.Replace(apiTestList[8].url, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)
	apiTestList[8].url = strings.Replace(apiTestList[8].url, "{tripPointID}", TripPointFromStr(apiTestList[5].actualResponse).ID, 1)

	//setup delete trip point test
	apiTestList[9].url = strings.Replace(apiTestList[9].url, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)
	apiTestList[9].url = strings.Replace(apiTestList[9].url, "{tripPointID}", TripPointFromStr(apiTestList[5].actualResponse).ID, 1)

	// setup delete test (url)
	apiTestList[10].url = strings.Replace(apiTestList[10].url, "{tripID}", TripFromStr(apiTestList[3].actualResponse).ID, 1)
	// run update test
	runAPITests(t, router, apiTestList[6:10])
}

func GetUpdateTrip(tripCreate string, tripUpdate string) string {
	tripC := TripFromStr(tripCreate)
	tripU := TripFromStr(tripUpdate)

	tripU.ID = tripC.ID

	serializedTripUpdate, _ := json.Marshal(tripU)

	return string(serializedTripUpdate)
}

func GetUpdateTripPoint(tripPointCreate string, tripPointUpdate string) string {
	tripPointC := TripPointFromStr(tripPointCreate)
	tripPointU := TripPointFromStr(tripPointUpdate)

	tripPointU.ID = tripPointC.ID
	tripPointU.TripID = tripPointC.TripID

	serializedTripUpdate, _ := json.Marshal(tripPointU)

	return string(serializedTripUpdate)
}

func TripFromStr(tripStr string) tripsgo.Trip {
	trip := tripsgo.Trip{}

	tripsgo.Debug.Println(tripStr)

	errCreate := json.Unmarshal([]byte(tripStr), &trip)
	if errCreate != nil {
		log.Println("TripFromStr - Invalid trip string")
		log.Fatal(errCreate)
	}

	return trip
}

func TripPointFromStr(tripPointStr string) tripsgo.TripPoint {
	tripPoint := tripsgo.TripPoint{}

	errCreate := json.Unmarshal([]byte(tripPointStr), &tripPoint)
	if errCreate != nil {
		log.Println("TripPointFromStr - Invalid trip point string")
		log.Fatal(errCreate)
	}

	tripsgo.Debug.Println(tripPointStr)

	return tripPoint
}
