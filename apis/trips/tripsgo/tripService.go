package tripsgo

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"

	_ "github.com/denisenkom/go-mssqldb" //vscode deletes this import if it is not a blank import
	"github.com/gorilla/mux"
)

// Trip Service Methods

// getTripByID - gets a trip by its trip id
func getTripByID(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	//Build Query
	var query = SelectTripByIDQuery(params["tripID"])

	//Execute Query
	row, err := FirstOrDefault(query)

	if err != nil {
		var msg = "getTripsByID - Error while retrieving trip from database"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	var trip Trip

	errScan := row.Scan(
		&trip.ID,
		&trip.Name,
		&trip.UserID,
		&trip.RecordedTimeStamp,
		&trip.EndTimeStamp,
		&trip.Rating,
		&trip.IsComplete,
		&trip.HasSimulatedOBDData,
		&trip.AverageSpeed,
		&trip.FuelUsed,
		&trip.HardStops,
		&trip.HardAccelerations,
		&trip.Distance,
		&trip.Created,
		&trip.UpdatedAt)

	if errScan != nil {
		var msg = fmt.Sprintf("No trip with ID '%s' found", params["tripID"])
		logMessage(msg)
		// fmt.Fprintf(w, msg)
		http.NotFound(w, r)
		return
	}

	serializedTrip, _ := json.Marshal(trip)

	fmt.Fprintf(w, string(serializedTrip))
}

// getAllTrips - get all trips
func getAllTrips(w http.ResponseWriter, r *http.Request) {

	var query = SelectAllTripsQuery()

	tripRows, err := ExecuteQuery(query)

	if err != nil {
		var msg = "getAllTrips - Query Failed to Execute."
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	trips := []Trip{}

	for tripRows.Next() {
		var r Trip
		err := tripRows.Scan(
			&r.ID,
			&r.Name,
			&r.UserID,
			&r.RecordedTimeStamp,
			&r.EndTimeStamp,
			&r.Rating,
			&r.IsComplete,
			&r.HasSimulatedOBDData,
			&r.AverageSpeed,
			&r.FuelUsed,
			&r.HardStops,
			&r.HardAccelerations,
			&r.Distance,
			&r.Created,
			&r.UpdatedAt)

		if err != nil {
			var msg = "GetAllTrips - Error scanning Trips"
			logError(err, msg)
			http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
			return
		}

		trips = append(trips, r)
	}

	tripsJSON, _ := json.Marshal(trips)

	fmt.Fprintf(w, string(tripsJSON))
}

// getAllTripsForUser - get all trips for a given user
func getAllTripsForUser(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	var query = SelectAllTripsForUserQuery(params["userID"])

	tripRows, err := ExecuteQuery(query)

	if err != nil {
		var msg = "getAllTripsForUser - Error while retrieving trips from database"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	trips := []Trip{}

	for tripRows.Next() {
		var r Trip
		err := tripRows.Scan(&r.ID,
			&r.Name,
			&r.UserID,
			&r.RecordedTimeStamp,
			&r.EndTimeStamp,
			&r.Rating,
			&r.IsComplete,
			&r.HasSimulatedOBDData,
			&r.AverageSpeed,
			&r.FuelUsed,
			&r.HardStops,
			&r.HardAccelerations,
			&r.Distance,
			&r.Created,
			&r.UpdatedAt)

		if err != nil {
			var msg = "getAllTripsForUser - Error scanning Trips"
			logError(err, msg)
			http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
			return
		}

		trips = append(trips, r)
	}

	tripsJSON, _ := json.Marshal(trips)

	fmt.Fprintf(w, string(tripsJSON))
}

// deleteTrip - deletes a single trip and its associated trip points for a user
func deleteTrip(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	var deleteTripPointsQuery = DeleteTripPointsForTripQuery(params["tripID"])
	var deleteTripsQuery = DeleteTripQuery(params["tripID"])

	result, err := ExecuteNonQuery(deleteTripPointsQuery)

	if err != nil {
		var msg = "Error while deleting trip points from database"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	// Debug.Println(fmt.Sprintln(`Deleted trip points for Trip '%s'`, params["tripID"]))

	result, err = ExecuteNonQuery(deleteTripsQuery)

	if err != nil {
		var msg = "Error while deleting trip from database"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	// Debug.Println(fmt.Sprintln("Deleted trip '%s'", params["tripID"]))

	serializedResult, _ := json.Marshal(result)

	fmt.Fprintf(w, string(serializedResult))
}

// updateTrip - update a trip
func updateTrip(w http.ResponseWriter, r *http.Request) {
	params := mux.Vars(r)

	tripID := params["tripID"]

	var trip Trip

	body, err := ioutil.ReadAll(r.Body)

	defer r.Body.Close()

	if err != nil {
		var msg = "Update Trip - Error reading trip request body"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	err = json.Unmarshal(body, &trip)

	if err != nil {
		var msg = "Update Trip - Error while decoding trip json"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	trip.ID = tripID

	updateQuery := UpdateTripQuery(trip)

	result, err := ExecuteNonQuery(updateQuery)

	if err != nil {
		var msg = "Error updating trip on the database." + string(result)
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	serializedTrip, _ := json.Marshal(trip)

	fmt.Fprintf(w, string(serializedTrip))
}

// createTrip - create a trip for a user.  This method does not create the associated trip points, only the trip.
func createTrip(w http.ResponseWriter, r *http.Request) {
	//params := mux.Vars(r)

	body, err := ioutil.ReadAll(r.Body)

	var trip Trip

	err = json.Unmarshal(body, &trip)

	if err != nil {
		var msg = "Error while decoding json"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	insertQuery := createTripQuery(trip)

	var newTripID newTrip

	result, err := ExecuteQuery(insertQuery)

	if err != nil {
		var msg = "Error while inserting trip into database"
		logError(err, msg)
		http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		return
	}

	for result.Next() {
		err = result.Scan(&newTripID.ID)

		if err != nil {
			var msg = "Error while retrieving last id"
			logError(err, msg)
			http.Error(w, SerializeError(err, msg), http.StatusInternalServerError)
		}
	}

	trip.ID = newTripID.ID

	serializedTrip, _ := json.Marshal(trip)

	fmt.Fprintf(w, string(serializedTrip))
}

type newTrip struct {
	ID string
}

// End of Trip Service Methods
