package tripsgo

// Healthcheck - Structure for healthcheck response body
type Healthcheck struct {

	//
	Message string `json:"message,omitempty"`

	//
	Status string `json:"status,omitempty"`
}
