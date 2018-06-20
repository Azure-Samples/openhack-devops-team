package tripsgo

import (
	"fmt"
	"net/http"
	"os"
	"time"
)

func swaggerDocsJSON(w http.ResponseWriter, r *http.Request) {
	fData, err := os.Open("./api/swagger.json")
	if err != nil {
		var msg = fmt.Sprintf("swaggerDocsJson - Unable to open and read swagger.json : %v", err)
		w.WriteHeader(http.StatusInternalServerError)
		Info.Println(msg)
		http.Error(w, msg, -1)
		return
	}
	http.ServeContent(w, r, "swagger.json", time.Now(), fData)
}
