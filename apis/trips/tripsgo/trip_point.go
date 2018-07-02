package tripsgo

import (
	"database/sql"
	"time"
)

// TripPoint - Represents a single point record in a trip
type TripPoint struct {

	// Trip Point ID
	ID string `json:"Id,omitempty"`

	// Trip ID
	TripID string `json:"TripId,omitempty"`

	Latitude float32 `json:"Latitude,omitempty"`

	Longitude float32 `json:"Longitude,omitempty"`

	Speed float32 `json:"Speed,omitempty"`

	RecordedTimeStamp string `json:"RecordedTimeStamp,omitempty"`

	Sequence int32 `json:"Sequence,omitempty"`

	RPM float32 `json:"RPM,omitempty"`

	ShortTermFuelBank float32 `json:"ShortTermFuelBank,omitempty"`

	LongTermFuelBank float32 `json:"LongTermFuelBank,omitempty"`

	ThrottlePosition float32 `json:"ThrottlePosition,omitempty"`

	RelativeThrottlePosition float32 `json:"RelativeThrottlePosition,omitempty"`

	Runtime float32 `json:"Runtime,omitempty"`

	DistanceWithMalfunctionLight float32 `json:"DistanceWithMalfunctionLight,omitempty"`

	EngineLoad float32 `json:"EngineLoad,omitempty"`

	MassFlowRate float32 `json:"MassFlowRate,omitempty"`

	EngineFuelRate float32 `json:"EngineFuelRate,omitempty"`

	VIN sql.NullString `json:"VIN,omitempty"`

	HasOBDData bool `json:"HasOBDData,omitempty"`

	HasSimulatedOBDData bool `json:"HasSimulatedOBDData,omitempty"`

	CreatedAt time.Time `json:"CreatedAt,omitempty"`

	UpdatedAt time.Time `json:"UpdatedAt,omitempty"`

	Deleted bool `json:"Deleted,omitempty"`
}
