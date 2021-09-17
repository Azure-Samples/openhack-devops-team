package tripsgo

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestSerializeErrorReturnsJsonIncludesErrorMessageUnit(t *testing.T) {
	//arrange
	expected := "{\"Message\":\"This is a fake error\"}"
	err := errors.New("This is a fake error")
	//act
	actual := SerializeError(err, "")
	//assert
	assert.Equal(t, expected, actual)
}

func TestSerializeErrorReturnsJsonIncludesCustomMessageUnit(t *testing.T) {
	//arrange
	expected := "{\"Message\":\"more data: This is a fake error\"}"
	err := errors.New("This is a fake error")
	//act
	actual := SerializeError(err, "more data")
	//assert
	assert.Equal(t, expected, actual)
}
