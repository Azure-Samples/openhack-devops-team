package tripsgo

import (
	"encoding/json"
	"strings"
)

// SerializeError - Serialize Error information to JSON format.
func SerializeError(e error, customMessage string) string {
	var errorMessage struct {
		Message string
	}

	if customMessage != "" {
		message := []string{customMessage, e.Error()}
		errorMessage.Message = strings.Join(message, ": ")
	} else {
		errorMessage.Message = e.Error()
	}

	serializedError, _ := json.Marshal(errorMessage)

	return string(serializedError)
}
