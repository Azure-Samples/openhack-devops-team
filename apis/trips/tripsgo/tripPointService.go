package tripsgo

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"strconv"

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
		LogError(err, msg)
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
			LogError(err, msg)
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

	var query = selectTripPointsForTripQuery(tripPointID)

	row, err := FirstOrDefault(query)

	if err != nil {
		var msg = "Error while retrieving trip point from database"
		LogError(err, msg)
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
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	serializedTripPoint, _ := json.Marshal(tripPoint)

	fmt.Fprintf(w, string(serializedTripPoint))
}

func createTripPoint(w http.ResponseWriter, r *http.Request) {
	tripID := r.FormValue("tripId")

	body, err := ioutil.ReadAll(r.Body)

	var tripPoint TripPoint

	err = json.Unmarshal(body, &tripPoint)

	if err != nil {
		var msg = "Error while decoding json"
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	tripPoint.TripID = tripID

	insertQuery := fmt.Sprintf("DECLARE @tempReturn TABLE (TripPointId NVARCHAR(128)); INSERT INTO TripPoints ([TripId], [Latitude], [Longitude], [Speed], [RecordedTimeStamp], [Sequence], [RPM], [ShortTermFuelBank], [LongTermFuelBank], [ThrottlePosition], [RelativeThrottlePosition], [Runtime], [DistanceWithMalfunctionLight], [EngineLoad], [EngineFuelRate], [MassFlowRate], [HasOBDData], [HasSimulatedOBDData], [VIN], [Deleted]) OUTPUT Inserted.ID INTO @tempReturn VALUES ('%s', '%s', '%s', '%s', '%s', %d, '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', 'false'); SELECT TripPointId FROM @tempReturn",
		tripPoint.TripID,
		tripPoint.Latitude,
		tripPoint.Longitude,
		tripPoint.Speed,
		tripPoint.RecordedTimeStamp,
		tripPoint.Sequence,
		tripPoint.RPM,
		tripPoint.ShortTermFuelBank,
		tripPoint.LongTermFuelBank,
		tripPoint.ThrottlePosition,
		tripPoint.RelativeThrottlePosition,
		tripPoint.Runtime,
		tripPoint.DistanceWithMalfunctionLight,
		tripPoint.EngineLoad,
		tripPoint.MassFlowRate,
		tripPoint.EngineFuelRate,
		strconv.FormatBool(tripPoint.HasOBDData),
		strconv.FormatBool(tripPoint.HasSimulatedOBDData),
		tripPoint.VIN)

	fmt.Fprintf(w, insertQuery)

	// var newTripPoint NewTripPoint

	// result, err := ExecuteQuery(insertQuery)

	// if err != nil {
	// 	fmt.Fprintf(w, SerializeError(err, "Error while inserting Trip Point onto database"))
	// 	return
	// }

	// for result.Next() {
	// 	err = result.Scan(&newTripPoint.Id)

	// 	if err != nil {
	// 		fmt.Fprintf(w, SerializeError(err, "Error while retrieving last id"))
	// 	}
	// }

	// serializedTripPoint, _ := json.Marshal(newTripPoint)

	// fmt.Fprintf(w, string(serializedTripPoint))
}

func updateTripPoint(w http.ResponseWriter, r *http.Request) {
	tripPointID := r.FormValue("id")

	body, err := ioutil.ReadAll(r.Body)

	defer r.Body.Close()

	if err != nil {
		var msg = "Error while reading request body"
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	var tripPoint TripPoint

	err = json.Unmarshal(body, &tripPoint)

	if err != nil {
		var msg = "Error while decoding json"
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	updateQuery := fmt.Sprintf("UPDATE [TripPoints] SET [TripId] = '%s',[Latitude] = '%s',[Longitude] = '%s',[Speed] = '%s',[RecordedTimeStamp] = '%s',[Sequence] = %d,[RPM] = '%s',[ShortTermFuelBank] = '%s',[LongTermFuelBank] = '%s',[ThrottlePosition] = '%s',[RelativeThrottlePosition] = '%s',[Runtime] = '%s',[DistanceWithMalfunctionLight] = '%s',[EngineLoad] = '%s',[MassFlowRate] = '%s',[EngineFuelRate] = '%s',[HasOBDData] = '%s',[HasSimulatedOBDData] = '%s',[VIN] = '%s' WHERE Id = '%s'",
		tripPoint.TripID,
		tripPoint.TripID,
		tripPoint.Latitude,
		tripPoint.Longitude,
		tripPoint.Speed,
		tripPoint.RecordedTimeStamp,
		tripPoint.Sequence,
		tripPoint.RPM,
		tripPoint.ShortTermFuelBank,
		tripPoint.LongTermFuelBank,
		tripPoint.ThrottlePosition,
		tripPoint.RelativeThrottlePosition,
		tripPoint.Runtime,
		tripPoint.DistanceWithMalfunctionLight,
		tripPoint.EngineLoad,
		tripPoint.MassFlowRate,
		tripPoint.EngineFuelRate,
		strconv.FormatBool(tripPoint.HasOBDData),
		strconv.FormatBool(tripPoint.HasSimulatedOBDData),
		tripPoint.VIN,
		tripPointID)

	result, err := ExecuteNonQuery(updateQuery)

	if err != nil {
		var msg = "Error while patching Trip Point on the database"
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	fmt.Fprintf(w, string(result))
}

func deleteTripPoint(w http.ResponseWriter, r *http.Request) {
	tripPointID := r.FormValue("id")

	deleteTripPointQuery := fmt.Sprintf("UPDATE TripPoints SET Deleted = 1 WHERE Id = '%s'", tripPointID)

	result, err := ExecuteNonQuery(deleteTripPointQuery)

	if err != nil {
		var msg = "Error while deleting trip point from database"
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	serializedResult, _ := json.Marshal(result)

	fmt.Fprintf(w, string(serializedResult))
}

func getMaxSequence(w http.ResponseWriter, r *http.Request) {
	tripID := r.FormValue("id")

	query := fmt.Sprintf("SELECT MAX(Sequence) as MaxSequence FROM TripPoints where tripid = '%s'", tripID)

	row, err := FirstOrDefault(query)

	if err != nil {
		var msg = "Error while querying Max Sequence"
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	var MaxSequence string

	err = row.Scan(&MaxSequence)

	if err != nil {
		var msg = "Error while obtaining max sequence"
		LogError(err, msg)
		fmt.Fprintf(w, SerializeError(err, msg))
		return
	}

	fmt.Fprintf(w, MaxSequence)
}

// End of Trip Point Service Methods

type newTripPoint struct {
	ID string
}
