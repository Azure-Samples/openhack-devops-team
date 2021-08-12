package tripsgo

import (
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestUnitdeleteTripPointQuery(t *testing.T) {
	//arrange
	var expected = `UPDATE TripPoints
		SET Deleted = 1
		WHERE Id = '1234'`
	//act
	query := deleteTripPointQuery("1234")
	//assert
	if query != expected {
		t.Errorf("Error \nExpected: %s \nGot: %s", expected, query)
	}
}

func TestUnitupdateTripPointQuery(t *testing.T) {
	//arrange
	tripPoint := TripPoint{
		ID:                           "abcd",
		TripID:                       "a_trip",
		Latitude:                     51.5244282,
		Longitude:                    -0.0784379,
		Speed:                        185.2,
		RecordedTimeStamp:            "a_timestamp",
		Sequence:                     1,
		RPM:                          4000,
		ShortTermFuelBank:            1,
		LongTermFuelBank:             2,
		ThrottlePosition:             3,
		RelativeThrottlePosition:     4,
		Runtime:                      5,
		DistanceWithMalfunctionLight: 6,
		EngineLoad:                   7,
		MassFlowRate:                 8,
		EngineFuelRate:               9,
		HasOBDData:                   true,
		HasSimulatedOBDData:          false,
		CreatedAt:                    time.Now(),
		UpdatedAt:                    time.Now(),
		Deleted:                      false,
	}

	var expected = `UPDATE [TripPoints]
			SET [TripId] = 'a_trip',
			[Latitude] = '%!s(float32=51.52443)',
			[Longitude] = '%!s(float32=-0.0784379)',
			[Speed] = '%!s(float32=185.2)',
			[RecordedTimeStamp] = 'a_timestamp',
			[Sequence] = 1,[RPM] = '%!s(float32=4000)',
			[ShortTermFuelBank] = '%!s(float32=1)',
			[LongTermFuelBank] = '%!s(float32=2)',
			[ThrottlePosition] = '%!s(float32=3)',
			[RelativeThrottlePosition] = '%!s(float32=4)',
			[Runtime] = '%!s(float32=5)',
			[DistanceWithMalfunctionLight] = '%!s(float32=6)',
			[EngineLoad] = '%!s(float32=7)',
			[MassFlowRate] = '%!s(float32=8)',
			[EngineFuelRate] = '%!s(float32=9)',
			[HasOBDData] = 'true',
			[HasSimulatedOBDData] = 'false',
			[VIN] = '{ %!s(bool=false)}'
		WHERE Id = 'abcd'`
	//act
	query := updateTripPointQuery(tripPoint)
	//assert
	assert.Equal(t, expected, query)
}

func TestSelectAllTripsQueryUnit(t *testing.T) {
	//arrange
	var expected = `SELECT
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
	//act
	query := SelectAllTripsQuery()
	//assert
	assert.Equal(t, expected, query)
}

func TestSelectAllTripsForUserQueryUnit(t *testing.T) {
	//arrange
	var expected = `SELECT
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
	WHERE UserId ='fake_user'
	AND Deleted = 0`
	//act
	query := SelectAllTripsForUserQuery("fake_user")
	//assert
	assert.Equal(t, expected, query)
}

func TestDeleteTripPointsForTripQueryUnit(t *testing.T) {
	//arrange
	var expected = `UPDATE TripPoints SET Deleted = 1 WHERE TripId = 'trip_123'`
	//act
	query := DeleteTripPointsForTripQuery("trip_123")
	//assert
	assert.Equal(t, expected, query)
}

func TestDeleteTripQueryUnit(t *testing.T) {
	//arrange
	var expected = `UPDAte Trips SET Deleted = 1 WHERE Id = 'trip_123'`
	//act
	query := DeleteTripQuery("trip_123")
	//assert
	assert.Equal(t, expected, query)
}

func TestSelectTripByIDQueryUnit(t *testing.T) {
	//arrange
	var expected = `SELECT
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
		WHERE Id = 'trip_123'
		AND Deleted = 0`
	//act
	query := SelectTripByIDQuery("trip_123")
	//assert
	assert.Equal(t, expected, query)
}

func TestSelectTripPointsForTripPointIDQueryUnit(t *testing.T) {
	//arrange
	var expected = `SELECT
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
		WHERE Id = 'point_ab'
		AND Deleted = 0`
	//act
	query := selectTripPointsForTripPointIDQuery("point_ab")
	//assert
	assert.Equal(t, expected, query)
}

func TestUpdateTripQueryUnit(t *testing.T) {
	//arrange
	trip := Trip{
		ID:                  "abcd",
		Name:                "fake Trip",
		UserID:              "fake user",
		RecordedTimeStamp:   "now",
		EndTimeStamp:        "then",
		Rating:              1,
		IsComplete:          false,
		HasSimulatedOBDData: false,
		AverageSpeed:        88,
		FuelUsed:            23.2,
		HardStops:           8,
		HardAccelerations:   12,
		Distance:            5,
		Created:             time.Now(),
		UpdatedAt:           time.Now(),
		Deleted:             false,
	}
	var expected = `UPDATE Trips SET
	Name = 'fake Trip',
	UserId = 'fake user',
	RecordedTimeStamp = 'now',
	EndTimeStamp = 'then',
	Rating = 1,
	IsComplete = 'false',
	HasSimulatedOBDData = 'false',
	AverageSpeed = 88,
	FuelUsed = 23.2,
	HardStops = 8,
	HardAccelerations = 12,
	Distance = 5,
	UpdatedAt = GETDATE()
	WHERE Id = 'abcd'`
	//act
	query := UpdateTripQuery(trip)
	//assert
	assert.Equal(t, expected, query)
}

func TestCreateTripQueryUnit(t *testing.T) {
	//arrange
	trip := Trip{
		ID:                  "abcd",
		Name:                "fake Trip",
		UserID:              "fake user",
		RecordedTimeStamp:   "now",
		EndTimeStamp:        "then",
		Rating:              1,
		IsComplete:          false,
		HasSimulatedOBDData: false,
		AverageSpeed:        88,
		FuelUsed:            23.2,
		HardStops:           8,
		HardAccelerations:   12,
		Distance:            5,
		Created:             time.Now(),
		UpdatedAt:           time.Now(),
		Deleted:             false,
	}
	var expected = `DECLARE @tempReturn
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
				'fake Trip',
				'fake user',
				'now',
				'then',
				1,
				'false',
				'false',
				88,
				23.2,
				8,
				12,
				5,
				GETDATE(),
				'false');
			SELECT TripId FROM @tempReturn`
	//act
	query := createTripQuery(trip)
	//assert
	assert.Equal(t, expected, query)
}

func TestSelectTripPointsForTripQueryUnit(t *testing.T) {
	//arrange
	var expected = `SELECT
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
		TripId = 'trip_zzyzx'
	AND Deleted = 0`
	//act
	query := selectTripPointsForTripQuery("trip_zzyzx")
	//assert
	assert.Equal(t, expected, query)
}

func TestCreateTripPointQueryUnit(t *testing.T) {
	//arrange
	tripPoint := TripPoint{
		ID:                           "abcd",
		TripID:                       "a_trip",
		Latitude:                     51.5244282,
		Longitude:                    -0.0784379,
		Speed:                        185.2,
		RecordedTimeStamp:            "a_timestamp",
		Sequence:                     1,
		RPM:                          4000,
		ShortTermFuelBank:            1,
		LongTermFuelBank:             2,
		ThrottlePosition:             3,
		RelativeThrottlePosition:     4,
		Runtime:                      5,
		DistanceWithMalfunctionLight: 6,
		EngineLoad:                   7,
		MassFlowRate:                 8,
		EngineFuelRate:               9,
		HasOBDData:                   true,
		HasSimulatedOBDData:          false,
		CreatedAt:                    time.Now(),
		UpdatedAt:                    time.Now(),
		Deleted:                      false,
	}

	var expected = `DECLARE @tempReturn TABLE (TripPointId NVARCHAR(128));
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
		'fake_trip_id',
		51.52443,
		-0.0784379,
		185.2,
		'a_timestamp',
		1,
		4000,
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		'true',
		'false',
		'{ %!s(bool=false)}',
		GETDATE(),
		'false');
	SELECT TripPointId
	FROM @tempReturn`
	//act
	query := createTripPointQuery(tripPoint, "fake_trip_id")
	//assert
	assert.Equal(t, expected, query)
}
