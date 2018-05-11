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

// SelectAllTripsQuery - select all trips
func SelectAllTripsQuery() string {
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
func SelectAllTripsForUserQuery(userID string) string {
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
	Distance
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

	LogToConsole("updateTripQuery: " + formattedQuery)

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

	LogToConsole("createTripQuery: " + formattedQuery)

	return formattedQuery
}

func SelectTripPointsForTripQuery(tripID string) string {

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
		Runtime],
		[DistanceWithMalfunctionLight],
		[EngineLoad],
		[EngineFuelRate],
		[VIN]
	FROM [dbo].[TripPoints]
	WHERE
		TripId = '%s'
		Deleted = 0`

	var formattedQuery = fmt.Sprintf(
		query,
		tripID)

	LogToConsole("SelectTripPointsForTripQuery: " + formattedQuery)

	return formattedQuery
}
