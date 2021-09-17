package tripsgo

import (
	"fmt"
	"net/http"
	"os"
)

func versionGet(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/plain; charset=UTF-8")
	w.WriteHeader(http.StatusOK)

	version := os.Getenv("APP_VERSION")
	fmt.Fprintf(w, version)
}
