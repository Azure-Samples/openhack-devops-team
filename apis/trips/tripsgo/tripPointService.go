package tripsgo

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	"github.com/gorilla/mux"
)

// TripPoint Service Methods

func getTripPoints(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	var tripID = params["tripID"]

	var query = selectTripPointsForTripQuery(tripID)

	statement, err := ExecuteQuery(query)

	if err != nil {
		var msg = "Error while retrieving trip points from database"
		logError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	tripPointRows := []TripPoint{}

	for statement.Next() {
		var tp TripPoint
		err := statement.Scan(
			&tp.ID,
			&tp.TripID,
			&tp.Latitude,
			&tp.Longitude,
			&tp.Speed,
			&tp.RecordedTimeStamp,
			&tp.Sequence,
			&tp.RPM,
			&tp.ShortTermFuelBank,
			&tp.LongTermFuelBank,
			&tp.ThrottlePosition,
			&tp.RelativeThrottlePosition,
			&tp.Runtime,
			&tp.DistanceWithMalfunctionLight,
			&tp.EngineLoad,
			&tp.EngineFuelRate,
			&tp.VIN)

		if err != nil {
			var msg = "Error scanning Trip Points"
			logError(err, msg)
			fmt.Fprintf(w, SerializeError(err, msg))
			return
		}

		tripPointRows = append(tripPointRows, tp)
	}

	serializedReturn, _ := json.Marshal(tripPointRows)

	fmt.Fprintf(w, string(serializedReturn))
}

func getTripPointByID(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	tripPointID := params["tripPointID"]

	var query = selectTripPointsForTripPointIDQuery(tripPointID)

	row, err := FirstOrDefault(query)

	if err != nil {
		var msg = "Error while retrieving trip point from database"
		logError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	var tripPoint TripPoint

	err = row.Scan(
		&tripPoint.ID,
		&tripPoint.TripID,
		&tripPoint.Latitude,
		&tripPoint.Longitude,
		&tripPoint.Speed,
		&tripPoint.RecordedTimeStamp,
		&tripPoint.Sequence,
		&tripPoint.RPM,
		&tripPoint.ShortTermFuelBank,
		&tripPoint.LongTermFuelBank,
		&tripPoint.ThrottlePosition,
		&tripPoint.RelativeThrottlePosition,
		&tripPoint.Runtime,
		&tripPoint.DistanceWithMalfunctionLight,
		&tripPoint.EngineLoad,
		&tripPoint.EngineFuelRate,
		&tripPoint.VIN)

	if err != nil {
		var msg = "Failed to scan a trip point"
		logError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	serializedTripPoint, _ := json.Marshal(tripPoint)

	fmt.Fprintf(w, string(serializedTripPoint))
}

func createTripPoint(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	tripID := params["tripID"]

	body, err := ioutil.ReadAll(r.Body)

	var tripPoint TripPoint

	err = json.Unmarshal(body, &tripPoint)

	if err != nil {
		var msg = "Error while decoding json for trip point"
		logError(err, msg)
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	var query = createTripPointQuery(tripPoint, tripID)

	result, err := ExecuteQuery(query)

	if err != nil {
		var msg = "Error while inserting Trip Point into database"
		logError(err, msg)
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	for result.Next() {
		err = result.Scan(&tripPoint.ID)

		if err != nil {
			var msg = "Error retrieving trip point id"
			logError(err, msg)
			w.WriteHeader(http.StatusInternalServerError)
			fmt.Fprintf(w, SerializeError(err, msg))
		}
	}

	serializedTripPoint, _ := json.Marshal(tripPoint)

	fmt.Fprintf(w, string(serializedTripPoint))
}

func updateTripPoint(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	tripPointID := params["tripPointID"]

	body, err := ioutil.ReadAll(r.Body)

	defer r.Body.Close()

	if err != nil {
		var msg = "Error while decoding json for trip point"
		logError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	var tripPoint TripPoint

	err = json.Unmarshal(body, &tripPoint)

	if err != nil {
		var msg = "Error while decoding json"
		logError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	tripPoint.ID = tripPointID

	var query = updateTripPointQuery(tripPoint)

	result, err := ExecuteNonQuery(query)

	if err != nil {
		var msg = "Error while patching Trip Point on the database"
		logError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	fmt.Fprintf(w, string(result))
}

func deleteTripPoint(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	tripPointID := params["tripPointID"]

	var query = deleteTripPointQuery(tripPointID)

	result, err := ExecuteNonQuery(query)

	if err != nil {
		var msg = "Error while deleting trip point from database"
		logError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	serializedResult, _ := json.Marshal(result)

	fmt.Fprintf(w, string(serializedResult))
}

// func getMaxSequence(w http.ResponseWriter, r *http.Request) {
// 	tripID := r.FormValue("id")

// 	query := fmt.Sprintf("SELECT MAX(Sequence) as MaxSequence FROM TripPoints where tripid = '%s'", tripID)

// 	row, err := FirstOrDefault(query)

// 	if err != nil {
// 		var msg = "Error while querying Max Sequence"
// 		logError(err, msg)
// 		fmt.Fprintf(w, SerializeError(err, msg))
// 		return
// 	}

// 	var MaxSequence string

// 	err = row.Scan(&MaxSequence)

// 	if err != nil {
// 		var msg = "Error while obtaining max sequence"
// 		logError(err, msg)
// 		fmt.Fprintf(w, SerializeError(err, msg))
// 		return
// 	}

// 	fmt.Fprintf(w, MaxSequence)
// }

type newTripPoint struct {
	ID string
}
