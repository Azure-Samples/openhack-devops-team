package tripsgo

import (
	"flag"
	"fmt"
	"net/http"
	"os"

	"github.com/codemodus/swagui"
	"github.com/codemodus/swagui/suidata3"
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
	var def = "/api/json/swagger.json"

	var provider = suidata3.New()

	ui, err := swagui.New(http.NotFoundHandler(), provider)
	if err != nil {
		Info.Println(err)
		os.Exit(1)
	}

	router.
		Methods(route.Method).
		Name(route.Name).
		Handler(ui.Handler(def))

	router.
		Methods(route.Method).
		Path("/api/docs/trips/{dir}/{fileName}").
		Name("*").
		Handler(ui.Handler(def))

	router.
		Methods(route.Method).
		Path("/api/docs/trips/{fileName}").
		Name("Swagger UI JS").
		Handler(ui.Handler(def))
}

var docsRoute = Route{
	"swagger-ui",
	"GET",
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
		"GET",
		"/api/json/swagger.json",
		swaggerDocsJSON,
	},

	Route{
		"CreateTrip",
		"POST",
		"/api/trips",
		createTrip,
	},

	Route{
		"CreateTripPoint",
		"POST",
		"/api/trips/{tripID}/trippoints",
		createTripPoint,
	},

	Route{
		"DeleteTrip",
		"DELETE",
		"/api/trips/{tripID}",
		deleteTrip,
	},

	Route{
		"DeleteTripPoint",
		"DELETE",
		"/api/trips/{tripID}/trippoints/{tripPointID}",
		deleteTripPoint,
	},

	Route{
		"GetAllTrips",
		"GET",
		"/api/trips",
		getAllTrips,
	},

	Route{
		"GetAllTripsForUser",
		"GET",
		"/api/trips/user/{userID}",
		getAllTripsForUser,
	},

	Route{
		"GetTripById",
		"GET",
		"/api/trips/{tripID}",
		getTripByID,
	},

	Route{
		"GetTripPointByID",
		"GET",
		"/api/trips/{tripID}/trippoints/{tripPointID}",
		getTripPointByID,
	},

	Route{
		"GetTripPoints",
		"GET",
		"/api/trips/{tripID}/trippoints",
		getTripPoints,
	},

	Route{
		"HealthcheckGet",
		"GET",
		"/api/healthcheck/trips",
		healthcheckGet,
	},

	Route{
		"UpdateTrip",
		"PATCH",
		"/api/trips/{tripID}",
		updateTrip,
	},

	Route{
		"UpdateTripPoint",
		"PATCH",
		"/api/trips/{tripID}/trippoints/{tripPointID}",
		updateTripPoint,
	},

	Route{
		"VersionGet",
		"GET",
		"/api/version/trips",
		versionGet,
	},	
}
