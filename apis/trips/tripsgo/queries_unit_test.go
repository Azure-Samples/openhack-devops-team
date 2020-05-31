package tripsgo

import (
	"testing"
	"time"
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
	if query != expected {
		t.Errorf("Error \nExpected: %s \nGot: %s", expected, query)
	}
}
