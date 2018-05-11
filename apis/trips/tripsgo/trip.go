package tripsgo

import (
	"time"
)

// Trip - Represents a single trip by a user with its associated set of trip points.
type Trip struct {

	// Trip ID
	ID string `json:"Id"`

	Name string `json:"Name"`

	// User's unique identity
	UserID string `json:"UserId"`

	RecordedTimeStamp string `json:"RecordedTimeStamp"`

	EndTimeStamp string `json:"EndTimeStamp"`

	Rating int32 `json:"Rating"`

	IsComplete bool `json:"IsComplete"`

	HasSimulatedOBDData bool `json:"HasSimulatedOBDData"`

	AverageSpeed float32 `json:"AverageSpeed"`

	FuelUsed float32 `json:"FuelUsed"`

	HardStops int64 `json:"HardStops"`

	HardAccelerations int64 `json:"HardAccelerations"`

	Distance float32 `json:"Distance"`

	Created time.Time `json:"Created"`

	UpdatedAt time.Time `json:"UpdatedAt"`

	Deleted bool `json:"Deleted,omitempty"`
}
