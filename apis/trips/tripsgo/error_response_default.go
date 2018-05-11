package tripsgo

// ErrorResponseDefault - Structure to return error information to service caller.
type ErrorResponseDefault struct {

	// Error code (if available)
	Status int32 `json:"status,omitempty"`

	// Error Message
	Message string `json:"message,omitempty"`
}
