package tripsgo

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

func getSwaggerJsonPath() string {
	if value, ok := os.LookupEnv("SWAGGER_JSON_PATH"); ok {
		return value
	}
	return "./api/swagger.json"
}

func swaggerDocsJSON(w http.ResponseWriter, r *http.Request) {
	swaggerPath := getSwaggerJsonPath()
	fData, err := os.Open(swaggerPath)
	if err != nil {
		var msg = fmt.Sprintf("swaggerDocsJson - Unable to open and read swagger.json : %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		Info.Println(msg)
		http.Error(w, msg, -1)
		return
	}
	http.ServeContent(w, r, "swagger.json", time.Now(), fData)
}
