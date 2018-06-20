package tripsgo

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/codemodus/swagui"
	"github.com/gorilla/mux"
)

var (
	du   = flag.String("du", getEnv("DOCS_URI", "http://localhost:8080"), "docs endpoint")
	wsbu = flag.String("wsbu", getEnv("WEB_SERVER_BASE_URI", "changeme"), "base portion of server uri")
)

// Route - object representing a route handler
type Route struct {
	Name        string
	Method      string
	Pattern     string
	HandlerFunc http.HandlerFunc
}

// Routes - Route handler collection
type Routes []Route

// NewRouter - Constructor
func NewRouter() *mux.Router {
	router := mux.NewRouter().StrictSlash(true)
	for _, route := range routes {
		CreateHandler(router, route)
	}

	// add docs route
	CreateDocsHandler(router, docsRoute)

	return router
}

// Index - Default route handler for service base uri
func Index(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Trips Service")
}

// CreateHandler - Create router handler
func CreateHandler(router *mux.Router, route Route) {
	var handler http.Handler
	handler = route.HandlerFunc
	handler = Logger(handler, route.Name)

	router.
		Methods(route.Method).
		Path(route.Pattern).
		Name(route.Name).
		Handler(handler)
}

// CreateDocsHandler - Create route handler for docs using SwagUI
func CreateDocsHandler(router *mux.Router, route Route) {
	// var handler http.Handler
	var options swagui.Options
	options.PathPrefix = route.Pattern
	options.DefaultURLParam = fmt.Sprintf("%s%s",
		*du,
		"/api/json/swagger.json")

	ui, err := swagui.New(&options)
	if err != nil {
		Info.Println(err)
		os.Exit(1)
	}

	// handler = ui.Handler()
	// handler = Logger(handler, route.Name)

	router.
		Methods(route.Method).
		Path(ui.PathPrefix()).
		Name(route.Name).
		Handler(ui.Handler())

	router.
		Methods(route.Method).
		Path("/api/docs/trips/{dir}/{fileName}").
		Name("*").
		Handler(ui.Handler())

	router.
		Methods(route.Method).
		Path("/api/docs/trips/{fileName}").
		Name("Swagger UI JS").
		Handler(ui.Handler())
}

var docsRoute = Route{
	"swagger-ui",
	strings.ToUpper("Get"),
	"/api/docs/trips/",
	nil,
}

var routes = Routes{
	Route{
		"Index",
		"GET",
		"/api/",
		Index,
	},

	Route{
		"swagger-json",
		strings.ToUpper("Get"),
		"/api/json/swagger.json",
		swaggerDocsJSON,
	},

	Route{
		"CreateTrip",
		strings.ToUpper("Post"),
		"/api/trips",
		createTrip,
	},

	Route{
		"CreateTripPoint",
		strings.ToUpper("Post"),
		"/api/trips/{tripID}/trippoints",
		createTripPoint,
	},

	Route{
		"DeleteTrip",
		strings.ToUpper("Delete"),
		"/api/trips/{tripID}",
		deleteTrip,
	},

	Route{
		"DeleteTripPoint",
		strings.ToUpper("Delete"),
		"/api/trips/{tripID}/trippoints/{tripPointID}",
		deleteTripPoint,
	},

	Route{
		"GetAllTrips",
		strings.ToUpper("Get"),
		"/api/trips",
		getAllTrips,
	},

	Route{
		"GetAllTripsForUser",
		strings.ToUpper("Get"),
		"/api/trips/user/{userID}",
		getAllTripsForUser,
	},

	Route{
		"GetTripById",
		strings.ToUpper("Get"),
		"/api/trips/{tripID}",
		getTripByID,
	},

	Route{
		"GetTripPointByID",
		strings.ToUpper("Get"),
		"/api/trips/{tripID}/trippoints/{tripPointID}",
		getTripPointByID,
	},

	Route{
		"GetTripPoints",
		strings.ToUpper("Get"),
		"/api/trips/{tripID}/trippoints",
		getTripPoints,
	},

	Route{
		"HealthcheckGet",
		strings.ToUpper("Get"),
		"/api/healthcheck/trips",
		healthcheckGet,
	},

	Route{
		"UpdateTrip",
		strings.ToUpper("Patch"),
		"/api/trips/{tripID}",
		updateTrip,
	},

	Route{
		"UpdateTripPoint",
		strings.ToUpper("Patch"),
		"/api/trips/{tripID}/trippoints/{tripPointID}",
		updateTripPoint,
	},
}
