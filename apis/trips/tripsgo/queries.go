package tripsgo

import (
	"fmt"
	"strconv"
)

// SelectTripByIDQuery - REQUIRED tripID value
func SelectTripByIDQuery(tripID string) string {
	return `SELECT
		Id,
		Name,
		UserId,
		RecordedTimeStamp,
		EndTimeStamp,
		Rating,
		IsComplete,
		HasSimulatedOBDData,
		AverageSpeed,
		FuelUsed,
		HardStops,
		HardAccelerations,
		Distance,
		CreatedAt,
		UpdatedAt
		FROM Trips
		WHERE Id = '` + tripID + `'
		AND Deleted = 0`
}

var SelectAllTripsQuery = selectAllTripsQuery

// SelectAllTripsQuery - select all trips
func selectAllTripsQuery() string {
	return `SELECT
	Id,
	Name,
	UserId,
	RecordedTimeStamp,
	EndTimeStamp,
	Rating,
	IsComplete,
	HasSimulatedOBDData,
	AverageSpeed,
	FuelUsed,
	HardStops,
	HardAccelerations,
	Distance,
	CreatedAt,
	UpdatedAt
	FROM Trips
	WHERE Deleted = 0`
}

// SelectAllTripsForUserQuery REQUIRED userID
var SelectAllTripsForUserQuery = selectAllTripsForUserQuery

func selectAllTripsForUserQuery(userID string) string {
	return `SELECT
	Id,
	Name,
	UserId,
	RecordedTimeStamp,
	EndTimeStamp,
	Rating,
	IsComplete,
	HasSimulatedOBDData,
	AverageSpeed,
	FuelUsed,
	HardStops,
	HardAccelerations,
	Distance,
	CreatedAt,
	UpdatedAt
	FROM Trips
	WHERE UserId ='` + userID + `'
	AND Deleted = 0`
}

// DeleteTripPointsForTripQuery - REQUIRED tripID
func DeleteTripPointsForTripQuery(tripID string) string {
	return fmt.Sprintf("UPDATE TripPoints SET Deleted = 1 WHERE TripId = '%s'", tripID)
}

// DeleteTripQuery - REQUIRED tripID
func DeleteTripQuery(tripID string) string {
	return fmt.Sprintf("UPDAte Trips SET Deleted = 1 WHERE Id = '%s'", tripID)
}

// UpdateTripQuery - REQUIRED trip object and tripID
func UpdateTripQuery(trip Trip) string {
	var query = `UPDATE Trips SET
	Name = '%s',
	UserId = '%s',
	RecordedTimeStamp = '%s',
	EndTimeStamp = '%s',
	Rating = %d,
	IsComplete = '%s',
	HasSimulatedOBDData = '%s',
	AverageSpeed = %g,
	FuelUsed = %g,
	HardStops = %d,
	HardAccelerations = %d,
	Distance = %g,
	UpdatedAt = GETDATE()
	WHERE Id = '%s'`

	var formattedQuery = fmt.Sprintf(
		query,
		trip.Name,
		trip.UserID,
		trip.RecordedTimeStamp,
		trip.EndTimeStamp,
		trip.Rating,
		strconv.FormatBool(trip.IsComplete),
		strconv.FormatBool(trip.HasSimulatedOBDData),
		trip.AverageSpeed,
		trip.FuelUsed,
		trip.HardStops,
		trip.HardAccelerations,
		trip.Distance,
		trip.ID)

	Debug.Println("updateTripQuery: " + formattedQuery)

	return formattedQuery
}

func createTripQuery(trip Trip) string {
	var query = `DECLARE @tempReturn
		TABLE (TripId NVARCHAR(128));
		INSERT INTO Trips (
			Name,
			UserId,
			RecordedTimeStamp,
			EndTimeStamp,
			Rating,
			IsComplete,
			HasSimulatedOBDData,
			AverageSpeed,
			FuelUsed,
			HardStops,
			HardAccelerations,
			Distance,
			UpdatedAt,
			Deleted)
			OUTPUT Inserted.ID
			INTO @tempReturn
			VALUES (
				'%s',
				'%s',
				'%s',
				'%s',
				%d,
				'%s',
				'%s',
				%g,
				%g,
				%d,
				%d,
				%g,
				GETDATE(),
				'false');
			SELECT TripId FROM @tempReturn`

	var formattedQuery = fmt.Sprintf(
		query,
		trip.Name,
		trip.UserID,
		trip.RecordedTimeStamp,
		trip.EndTimeStamp,
		trip.Rating,
		strconv.FormatBool(trip.IsComplete),
		strconv.FormatBool(trip.HasSimulatedOBDData),
		trip.AverageSpeed,
		trip.FuelUsed,
		trip.HardStops,
		trip.HardAccelerations,
		trip.Distance)

	Debug.Println("createTripQuery: " + formattedQuery)

	return formattedQuery
}

func selectTripPointsForTripQuery(tripID string) string {

	var query = `SELECT
		[Id],
		[TripId],
		[Latitude],
		[Longitude],
		[Speed],
		[RecordedTimeStamp],
		[Sequence],
		[RPM],
		[ShortTermFuelBank],
		[LongTermFuelBank],
		[ThrottlePosition],
		[RelativeThrottlePosition],
		[Runtime],
		[DistanceWithMalfunctionLight],
		[EngineLoad],
		[EngineFuelRate],
		[VIN]
	FROM [dbo].[TripPoints]
	WHERE
		TripId = '%s'
	AND Deleted = 0`

	var formattedQuery = fmt.Sprintf(
		query,
		tripID)

	Debug.Println("selectTripPointsForTripQuery: " + formattedQuery)

	return formattedQuery
}

func selectTripPointsForTripPointIDQuery(tripPointID string) string {
	var query = `SELECT
		[Id],
		[TripId],
		[Latitude],
		[Longitude],
		[Speed],
		[RecordedTimeStamp],
		[Sequence],
		[RPM],
		[ShortTermFuelBank],
		[LongTermFuelBank],
		[ThrottlePosition],
		[RelativeThrottlePosition],
		[Runtime],
		[DistanceWithMalfunctionLight],
		[EngineLoad],
		[EngineFuelRate],
		[VIN]
		FROM TripPoints
		WHERE Id = '%s'
		AND Deleted = 0`

	var formattedQuery = fmt.Sprintf(
		query,
		tripPointID)

	Debug.Println("selectTripPointsForTripPointIDQuery: " + formattedQuery)

	return formattedQuery
}

func createTripPointQuery(tripPoint TripPoint, tripID string) string {
	var query = `DECLARE @tempReturn TABLE (TripPointId NVARCHAR(128));
	INSERT INTO TripPoints (
		[TripId],
		[Latitude],
		[Longitude],
		[Speed],
		[RecordedTimeStamp],
		[Sequence],
		[RPM],
		[ShortTermFuelBank],
		[LongTermFuelBank],
		[ThrottlePosition],
		[RelativeThrottlePosition],
		[Runtime],
		[DistanceWithMalfunctionLight],
		[EngineLoad],
		[EngineFuelRate],
		[MassFlowRate],
		[HasOBDData],
		[HasSimulatedOBDData],
		[VIN],
		[UpdatedAt],
		[Deleted])
	OUTPUT
		Inserted.ID
	INTO @tempReturn
	VALUES (
		'%s',
		%g,
		%g,
		%g,
		'%s',
		%d,
		%g,
		%g,
		%g,
		%g,
		%g,
		%g,
		%g,
		%g,
		%g,
		%g,
		'%s',
		'%s',
		'%s',
		GETDATE(),
		'false');
	SELECT TripPointId
	FROM @tempReturn`

	var formattedQuery = fmt.Sprintf(
		query,
		tripID,
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

	Debug.Println("createTripPointQuery: " + formattedQuery)

	return formattedQuery
}

func updateTripPointQuery(tripPoint TripPoint) string {
	var query = `UPDATE [TripPoints]
			SET [TripId] = '%s',
			[Latitude] = '%s',
			[Longitude] = '%s',
			[Speed] = '%s',
			[RecordedTimeStamp] = '%s',
			[Sequence] = %d,[RPM] = '%s',
			[ShortTermFuelBank] = '%s',
			[LongTermFuelBank] = '%s',
			[ThrottlePosition] = '%s',
			[RelativeThrottlePosition] = '%s',
			[Runtime] = '%s',
			[DistanceWithMalfunctionLight] = '%s',
			[EngineLoad] = '%s',
			[MassFlowRate] = '%s',
			[EngineFuelRate] = '%s',
			[HasOBDData] = '%s',
			[HasSimulatedOBDData] = '%s',
			[VIN] = '%s'
		WHERE Id = '%s'`

	var formattedQuery = fmt.Sprintf(
		query,
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
		tripPoint.ID)

	Debug.Println("updateTripPointQuery: " + formattedQuery)

	return formattedQuery
}

func deleteTripPointQuery(tripPointID string) string {
	var query = `UPDATE TripPoints
		SET Deleted = 1
		WHERE Id = '%s'`

	var formattedQuery = fmt.Sprintf(
		query,
		tripPointID)

	Debug.Println("deleteTripPointQuery: " + formattedQuery)

	return formattedQuery
}
