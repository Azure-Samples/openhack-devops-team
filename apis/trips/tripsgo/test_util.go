package tripsgo

import (
	"bytes"
	"net/http"
	"net/http/httptest"
	"strconv"
	"testing"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
	"github.com/stretchr/testify/assert"
)

// APITestCase needs to be exported to be accessed for test dir
type APITestCase struct {
	Tag              string
	Method           string
	URL              string
	Body             string
	Status           int
	ExpectedResponse string
	ActualResponse   string
}

func testAPI(router *mux.Router, method, URL, body string) *httptest.ResponseRecorder {
	req, _ := http.NewRequest(method, URL, bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")
	res := httptest.NewRecorder()
	router.ServeHTTP(res, req)
	return res
}

// RunAPITests needs to be exported to be accessed for test dir
func RunAPITests(t *testing.T, router *mux.Router, tests []APITestCase) {
	for i := 0; i < len(tests); i++ {
		res := testAPI(router, tests[i].Method, tests[i].URL, tests[i].Body)
		tests[i].ActualResponse = res.Body.String()
		Debug.Println(tests[i].Tag + " - " + tests[i].ActualResponse)
		assert.Equal(t, tests[i].Status, res.Code, tests[i].Tag)
		Info.Println(tests[i].Tag + "- Response Code:" + strconv.Itoa(res.Code))
		if tests[i].ExpectedResponse != "" {
			assert.JSONEq(t, tests[i].ExpectedResponse, res.Body.String(), tests[i].Tag)
		}
	}
}

func RunAPITestsPlainText(t *testing.T, router *mux.Router, tests []APITestCase) {
	for i := 0; i < len(tests); i++ {
		res := testAPI(router, tests[i].Method, tests[i].URL, tests[i].Body)
		tests[i].ActualResponse = res.Body.String()
		Debug.Println(tests[i].Tag + " - " + tests[i].ActualResponse)
		assert.Equal(t, tests[i].Status, res.Code, tests[i].Tag)
		Info.Println(tests[i].Tag + "- Response Code:" + strconv.Itoa(res.Code))
		if tests[i].ExpectedResponse != "" {
			assert.Equal(t, tests[i].ExpectedResponse, res.Body.String(), tests[i].Tag)
		}
	}
}

func resetDataAccessEnvVars() {
	var fls bool = false
	debug = &fls
	godotenv.Overload()
	RebindDataAccessEnvironmentVariables()
}
