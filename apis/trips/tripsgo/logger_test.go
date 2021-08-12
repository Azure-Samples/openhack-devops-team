package tripsgo

import (
	"bytes"
	"errors"
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLogMessagePrintToInfoLogUnit(t *testing.T) {
	//arrange
	info := new(bytes.Buffer)
	debug := new(bytes.Buffer)
	fatal := new(bytes.Buffer)
	InitLogging(info, debug, fatal)
	errorMessage := "This is a test message"
	//act
	logMessage(errorMessage)

	//assert
	actual := fmt.Sprint(info)
	assert.True(t, strings.Contains(actual, errorMessage))
}

func TestLogErrorPrintsMsgToInfoUnit(t *testing.T) {
	//arrange
	info := new(bytes.Buffer)
	debug := new(bytes.Buffer)
	fatal := new(bytes.Buffer)
	InitLogging(info, debug, fatal)
	errorMessage := "This is a test message"
	err := errors.New("This is a fake error")
	//act
	logError(err, errorMessage)

	//assert
	actual := fmt.Sprint(info)
	assert.True(t, strings.Contains(actual, errorMessage))
}

func TestLogErrorPrintsErrMessageToDebugUnit(t *testing.T) {
	//arrange
	info := new(bytes.Buffer)
	debug := new(bytes.Buffer)
	fatal := new(bytes.Buffer)
	InitLogging(info, debug, fatal)
	errorMessage := "This is a test message"
	err := errors.New("This is a fake error")
	//act
	logError(err, errorMessage)

	//assert
	actual := fmt.Sprint(debug)
	assert.True(t, strings.Contains(actual, "This is a fake error"))
}
