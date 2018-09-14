package tripsgo

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"time"
)

//
var (
	Info  *log.Logger
	Debug *log.Logger
	Fatal *log.Logger
)

// InitLogging - Initialize logging for trips api
func InitLogging(
	infoHandle io.Writer,
	debugHandle io.Writer,
	fatalHandle io.Writer) {

	Info = log.New(infoHandle,
		"INFO: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Debug = log.New(debugHandle,
		"DEBUG: ",
		log.Ldate|log.Ltime|log.Lshortfile)

	Fatal = log.New(fatalHandle,
		"FATAL: ",
		log.Ldate|log.Ltime|log.Lshortfile)
}

// Logger - basic console logger that writes request info to stdout
func Logger(inner http.Handler, name string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()

		inner.ServeHTTP(w, r)

		Info.Println(fmt.Sprintf(
			"%s %s %s %s",
			r.Method,
			r.RequestURI,
			name,
			time.Since(start),
		))
	})
}

func logMessage(msg string) {
	Info.Println(msg)
}

func logError(err error, msg string) {
	Info.Println(msg)
	Debug.Println(err.Error())
}
