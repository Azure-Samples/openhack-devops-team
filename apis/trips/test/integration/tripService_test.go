package tripsgo

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"testing"

	tripSvc "github.com/Azure-Samples/openhack-devops-team/apis/trips/tripsgo"
)

var tripID string

var apiTestList = []tripSvc.APITestCase{
	{
		Tag:    "t1 - Get all trips",
		Method: "GET",
		URL:    "/api/trips",
		Status: 200,
	},
	{
		Tag:    "t2 - Get a nonexistent trip",
		Method: "GET",
		URL:    "/api/trips/99999",
		Status: 404,
	},
	{
		Tag:    "t3 - Create a Trip",
		Method: "POST",
		URL:    "/api/trips",
		Body: `{
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
		Status: 200,
	},
	{
		Tag:    "t4 - Update a trip",
		Method: "PATCH",
		URL:    "/api/trips/{tripID}",
		Body: `{
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
		Status: 200,
	},
	{
		Tag:    "t5 - Create Trip Point",
		Method: "POST",
		URL:    "/api/trips/{tripID}/trippoints",
		Body: `{
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
		Status: 200,
	},
	{
		Tag:    "t6 - Update Trip Point",
		Method: "PATCH",
		URL:    "/api/trips/{tripID}/trippoints/{tripPointID}",
		Body: `{
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
		ExpectedResponse: "",
		Status:           200,
	},
	{
		Tag:    "t7 - Read Trip Points for Trip",
		Method: "GET",
		URL:    "/api/trips/{tripID}/trippoints",
		Status: 200,
	},
	{
		Tag:    "t8 - Read Trip Points By Trip Point ID",
		Method: "GET",
		URL:    "/api/trips/{tripID}/trippoints/{tripPointID}",
		Status: 200,
	},
	{
		Tag:    "t9 - Delete Trip Point",
		Method: "DELETE",
		URL:    "/api/trips/{tripID}/trippoints/{tripPointID}",
		Status: 200,
	},
	{
		Tag:    "t10 - Delete a Trip",
		Method: "DELETE",
		URL:    "/api/trips/{tripID}",
		Status: 200,
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
	tripSvc.RunAPITests(t, router, apiTestList[0:4])

	// setup update trip test (URL, Body, expected Response)
	apiTestList[4].URL = strings.Replace(apiTestList[4].URL, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)
	apiTestList[4].Body = GetUpdateTrip(apiTestList[3].ActualResponse, apiTestList[4].Body)
	apiTestList[4].ExpectedResponse = apiTestList[4].Body

	// setup create trip point test
	apiTestList[5].URL = strings.Replace(apiTestList[5].URL, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)
	apiTestList[5].Body = strings.Replace(apiTestList[5].Body, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)

	// run update trip and create trip point tests
	tripSvc.RunAPITests(t, router, apiTestList[4:6])

	// setup update trip point test
	apiTestList[6].URL = strings.Replace(apiTestList[6].URL, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)
	apiTestList[6].URL = strings.Replace(apiTestList[6].URL, "{tripPointID}", TripPointFromStr(apiTestList[5].ActualResponse).ID, 1)
	apiTestList[6].Body = GetUpdateTripPoint(apiTestList[5].ActualResponse, apiTestList[6].Body)
	//apiTestList[6].ExpectedResponse = apiTestList[6].Body

	// setup read trip points for trip test
	apiTestList[7].URL = strings.Replace(apiTestList[7].URL, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)

	// setup ready trip points by trip point id test
	apiTestList[8].URL = strings.Replace(apiTestList[8].URL, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)
	apiTestList[8].URL = strings.Replace(apiTestList[8].URL, "{tripPointID}", TripPointFromStr(apiTestList[5].ActualResponse).ID, 1)

	//setup delete trip point test
	apiTestList[9].URL = strings.Replace(apiTestList[9].URL, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)
	apiTestList[9].URL = strings.Replace(apiTestList[9].URL, "{tripPointID}", TripPointFromStr(apiTestList[5].ActualResponse).ID, 1)

	// setup delete test (URL)
	apiTestList[10].URL = strings.Replace(apiTestList[10].URL, "{tripID}", TripFromStr(apiTestList[3].ActualResponse).ID, 1)
	// run update test
	tripSvc.RunAPITests(t, router, apiTestList[6:10])
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

func TripFromStr(tripStr string) tripSvc.Trip {
	trip := tripSvc.Trip{}

	tripSvc.Debug.Println(tripStr)

	errCreate := json.Unmarshal([]byte(tripStr), &trip)
	if errCreate != nil {
		log.Println("TripFromStr - Invalid trip string")
		log.Fatal(errCreate)
	}

	return trip
}

func TripPointFromStr(tripPointStr string) tripSvc.TripPoint {
	tripPoint := tripSvc.TripPoint{}

	errCreate := json.Unmarshal([]byte(tripPointStr), &tripPoint)
	if errCreate != nil {
		log.Println("TripPointFromStr - Invalid trip point string")
		log.Fatal(errCreate)
	}

	tripSvc.Debug.Println(tripPointStr)

	return tripPoint
}
