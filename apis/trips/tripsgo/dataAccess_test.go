package tripsgo

import (
	"bytes"
	"fmt"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestExecuteQueryInvalidDriverReturnsErr(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)
	//arrange
	InitLogging(os.Stdout, os.Stdout, os.Stdout)
	os.Setenv("SQL_DRIVER", "not_a_real_driver")
	RebindDataAccessEnvironmentVariables()
	//act
	var query = SelectAllTripsForUserQuery("someUser")

	_, err := ExecuteQuery(query)

	//assert
	assert.NotNil(t, err)
}
func TestExecuteQueryConnectionSuccess(t *testing.T) {
	//act
	var query = SelectAllTripsForUserQuery("someUser")
	trips, err := ExecuteQuery(query)

	//assert
	assert.NotNil(t, trips)
	assert.Nil(t, err)
}

func TestExecuteQueryInvalidSqlReturnsErr(t *testing.T) {
	//arrange
	InitLogging(os.Stdout, os.Stdout, os.Stdout)

	//act
	var invalidSql = "Select Trips From *"
	_, err := ExecuteQuery(invalidSql)

	//assert
	assert.NotNil(t, err)
}

func TestExecuteQueryInvalidServerReturnsErr(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	InitLogging(os.Stdout, os.Stdout, os.Stdout)
	os.Setenv("SQL_SERVER", "not_a_real_driver")
	RebindDataAccessEnvironmentVariables()

	//act
	_, err := ExecuteQuery("SELECT TOP 1 ID FROM Trips")

	//assert
	assert.NotNil(t, err)
}

func TestExecuteNonQueryInvalidDriverReturnsErr(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)
	//arrange
	InitLogging(os.Stdout, os.Stdout, os.Stdout)
	os.Setenv("SQL_DRIVER", "not_a_real_driver")
	RebindDataAccessEnvironmentVariables()

	//act
	_, err := ExecuteNonQuery("fake non query sql")

	//assert
	assert.NotNil(t, err)
}

func TestExecuteNonQueryConnectionSuccess(t *testing.T) {
	//act
	_, err := ExecuteNonQuery("SELECT TOP 1 ID FROM Trips")

	//assert
	assert.Nil(t, err)
}

func TestExecuteNonQueryInvalidServerReturnsErr(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	InitLogging(os.Stdout, os.Stdout, os.Stdout)
	os.Setenv("SQL_SERVER", "not_a_real_server")
	RebindDataAccessEnvironmentVariables()

	//act
	_, err := ExecuteNonQuery("SELECT TOP 1 ID FROM Trips")

	//assert
	assert.NotNil(t, err)
}

func TestFirstOrDefaultInvalidDriverReturnsErr(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)
	//arrange
	InitLogging(os.Stdout, os.Stdout, os.Stdout)
	os.Setenv("SQL_DRIVER", "not_a_real_driver")
	RebindDataAccessEnvironmentVariables()

	//act
	_, err := FirstOrDefault("fake non query sql")

	//assert
	assert.NotNil(t, err)
}

func TestFirstOrDefaultConnectionSuccess(t *testing.T) {
	//act
	RebindDataAccessEnvironmentVariables()
	_, err := FirstOrDefault("SELECT TOP 1 ID FROM Trips")

	//assert
	assert.Nil(t, err)
}

func TestFirstOrDefaultInvalidServerReturnsErr(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	InitLogging(os.Stdout, os.Stdout, os.Stdout)
	os.Setenv("SQL_SERVER", "not_a_real_server")
	RebindDataAccessEnvironmentVariables()

	//act
	_, err := FirstOrDefault("SELECT TOP 1 ID FROM Trips")

	//assert
	assert.NotNil(t, err)
}

func TestExecuteNonQueryWritesLogIfDebugTrue(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)
	var tr bool = true
	debug = &tr

	//act
	ExecuteNonQuery("SELECT TOP 1 ID FROM Trips")

	//assert
	actual := fmt.Sprint(info)
	assert.True(t, actual != "")
}

func TestFirstOrDefaultWritesLogIfDebugTrue(t *testing.T) {
	defer t.Cleanup(resetDataAccessEnvVars)

	//arrange
	info := new(bytes.Buffer)
	InitLogging(info, os.Stdout, os.Stdout)
	var tr bool = true
	debug = &tr

	//act
	FirstOrDefault("SELECT TOP 1 ID FROM Trips")

	//assert
	actual := fmt.Sprint(info)
	assert.True(t, actual != "")
}
