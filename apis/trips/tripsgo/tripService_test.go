package tripsgo

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

var tripID string

var apiTestList = []APITestCase{
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
	{
		Tag:    "t11 - Get All Trips for User",
		Method: "GET",
		URL:    "/api/trips/user/SomeUser",
		Status: 200,
	},
}

func TestTripApis(t *testing.T) {
	router := NewRouter()
	var debug, present = os.LookupEnv("DEBUG_LOGGING")

	if present && debug == "true" {
		InitLogging(os.Stdout, os.Stdout, os.Stdout)
	} else {
		// if debug env is not present or false, do not log debug output to console
		InitLogging(os.Stdout, ioutil.Discard, os.Stdout)
	}
	RunAPITests(t, router, apiTestList[0:3])

	// setup update trip test (URL, Body, expected Response)
	apiTestList[3].URL = strings.Replace(apiTestList[3].URL, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)
	apiTestList[3].Body = GetUpdateTrip(apiTestList[2].ActualResponse, apiTestList[3].Body)
	apiTestList[3].ExpectedResponse = apiTestList[3].Body

	// setup create trip point test
	apiTestList[4].URL = strings.Replace(apiTestList[4].URL, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)
	apiTestList[4].Body = strings.Replace(apiTestList[4].Body, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)

	// run update trip and create trip point tests
	RunAPITests(t, router, apiTestList[3:5])

	// setup update trip point test
	apiTestList[5].URL = strings.Replace(apiTestList[5].URL, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)
	apiTestList[5].URL = strings.Replace(apiTestList[5].URL, "{tripPointID}", TripPointFromStr(apiTestList[4].ActualResponse).ID, 1)
	apiTestList[5].Body = GetUpdateTripPoint(apiTestList[4].ActualResponse, apiTestList[5].Body)

	// setup read trip points for trip test
	apiTestList[6].URL = strings.Replace(apiTestList[6].URL, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)

	// // setup ready trip points by trip point id test
	apiTestList[7].URL = strings.Replace(apiTestList[7].URL, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)
	apiTestList[7].URL = strings.Replace(apiTestList[7].URL, "{tripPointID}", TripPointFromStr(apiTestList[4].ActualResponse).ID, 1)

	// //setup delete trip point test
	apiTestList[8].URL = strings.Replace(apiTestList[8].URL, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)
	apiTestList[8].URL = strings.Replace(apiTestList[8].URL, "{tripPointID}", TripPointFromStr(apiTestList[4].ActualResponse).ID, 1)

	// setup delete test (URL)
	apiTestList[9].URL = strings.Replace(apiTestList[9].URL, "{tripID}", TripFromStr(apiTestList[2].ActualResponse).ID, 1)
	// run update test
	RunAPITests(t, router, apiTestList[5:10])

	RunAPITests(t, router, apiTestList[10:11])
}

func TestGetAllTripsReturnsServerErrorIfBadDbConnection(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	os.Setenv("SQL_DRIVER", "not_a_real_driver")
	RebindDataAccessEnvironmentVariables()
	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)
	var tr bool = true
	debug = &tr

	//act
	router := NewRouter()
	RunAPITestsPlainText(t, router, []APITestCase{
		{
			Tag:    "t1 - Get all trips",
			Method: "GET",
			URL:    "/api/trips",
			Status: 500,
		},
	})

	//assert
	actual := fmt.Sprint(info)
	assert.Contains(t, actual, "getAllTrips - Query Failed to Execute")
}

func TestGetAllTripsReturnsErrorScanningTripsIfMissingSqlFields(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	//oldSelectAllTripsQuery := func(SelectAllTripsQuery)
	var OldSelectAllTripsQuery = SelectAllTripsQuery
	SelectAllTripsQuery = func() string {
		return `SELECT
		Id
		FROM Trips
		WHERE Deleted = 0`
	}
	defer func() { SelectAllTripsQuery = OldSelectAllTripsQuery }()

	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)
	var tr bool = true
	debug = &tr

	//act
	router := NewRouter()
	RunAPITestsPlainText(t, router, []APITestCase{
		{
			Tag:    "t1 - Get all trips",
			Method: "GET",
			URL:    "/api/trips",
			Status: 500,
		},
	})

	//assert
	actual := fmt.Sprint(info)
	assert.Contains(t, actual, "GetAllTrips - Error scanning Trips")
}

func TestGetAllTripsForUsersReturnsServerErrorIfBadDbConnection(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	os.Setenv("SQL_DRIVER", "not_a_real_driver")
	RebindDataAccessEnvironmentVariables()
	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)
	var tr bool = true
	debug = &tr

	//act
	router := NewRouter()
	RunAPITestsPlainText(t, router, []APITestCase{
		{
			Tag:    "t11 - Get All Trips for User",
			Method: "GET",
			URL:    "/api/trips/user/SomeUser",
			Status: 500,
		},
	})

	//assert
	actual := fmt.Sprint(info)
	assert.Contains(t, actual, "getAllTripsForUser - Error while retrieving trips from database")
}

func TestGetAllTripsForUserReturnsErrorScanningTripsIfMissingSqlFields(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	//oldSelectAllTripsQuery := func(SelectAllTripsQuery)
	var OldSelectAllTripsForUserQuery = SelectAllTripsForUserQuery
	SelectAllTripsForUserQuery = func(userID string) string {
		return `SELECT
		Id
		FROM Trips
		WHERE UserId ='` + userID + `'
		AND Deleted = 0`
	}
	defer func() { SelectAllTripsForUserQuery = OldSelectAllTripsForUserQuery }()

	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)
	var tr bool = true
	debug = &tr

	//act
	router := NewRouter()
	RunAPITestsPlainText(t, router, []APITestCase{
		{
			Tag:    "t11 - Get All Trips for User",
			Method: "GET",
			URL:    "/api/trips/user/SomeUser",
			Status: 500,
		},
	})

	//assert
	actual := fmt.Sprint(info)
	assert.Contains(t, actual, "getAllTripsForUser - Error scanning Trips")
}

func TestCreateTripReturnsErrorifInvalidJsonBody(t *testing.T) {
	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)

	//act
	router := NewRouter()
	RunAPITestsPlainText(t, router, []APITestCase{
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
				"IsComplete":`,
			Status: 500,
		},
	})

	//assert
	actual := fmt.Sprint(info)
	assert.Contains(t, actual, "Error while decoding json")
}

func TestUpdateTripReturnsErrorifInvalidJsonBody(t *testing.T) {
	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)

	//act
	router := NewRouter()
	RunAPITestsPlainText(t, router, []APITestCase{
		{
			Tag:    "t4 - Update a trip",
			Method: "PATCH",
			URL:    "/api/trips/{tripID}",
			Body: `{
				"Name":"Trip UPDATE TEST",
				"UserId":"GO_TEST",
				"RecordedTimeStamp": "2018-04-19T19:08:16.03Z",
				"EndTimeStamp": "2018-04-19T19:42:49.573Z",
				"Rating":`,
			Status: 500,
		},
	})

	//assert
	actual := fmt.Sprint(info)
	assert.Contains(t, actual, "Update Trip - Error while decoding trip json")
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

func TripFromStr(tripStr string) Trip {
	trip := Trip{}

	Debug.Println("DEBUG: TripFromStr - " + tripStr)

	errCreate := json.Unmarshal([]byte(tripStr), &trip)
	if errCreate != nil {
		log.Println("TripFromStr - Invalid trip string")
		log.Fatal(errCreate)
	}

	return trip
}

func TripPointFromStr(tripPointStr string) TripPoint {
	tripPoint := TripPoint{}

	Debug.Println("DEBUG: TripPointFromStr - " + tripPointStr)

	errCreate := json.Unmarshal([]byte(tripPointStr), &tripPoint)
	if errCreate != nil {
		log.Println("TripPointFromStr - Invalid trip point string")
		log.Fatal(errCreate)
	}

	Debug.Println(tripPointStr)

	return tripPoint
}
