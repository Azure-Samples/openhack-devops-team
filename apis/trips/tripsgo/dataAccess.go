package tripsgo

import (
	"database/sql"
	"encoding/json"
	"flag"
	"fmt"
	"os"
)

func getEnv(key, fallback string) string {
	if value, ok := os.LookupEnv(key); ok {
		return value
	}
	return fallback
}

var (
	debug    = flag.Bool("debug", false, "enable debugging")
	password = flag.String("password", getEnv("SQL_PASSWORD", "changeme"), "the database password")
	port     = flag.Int("port", 1433, "the database port")
	server   = flag.String("server", getEnv("SQL_SERVER", "changeme.database.windows.net"), "the database server")
	user     = flag.String("user", getEnv("SQL_USER", "YourUserName"), "the database user")
	database = flag.String("d", getEnv("SQL_DBNAME", "mydrivingDB"), "db_name")
)

// ExecuteNonQuery - Execute a SQL query that has no records returned (Ex. Delete)
func ExecuteNonQuery(query string) (string, error) {
	connString := fmt.Sprintf("server=%s;database=%s;user id=%s;password=%s;port=%d", *server, *database, *user, *password, *port)

	if *debug {
		fmt.Printf("connString:%s\n", connString)
	}

	conn, err := sql.Open("mssql", connString)

	if err != nil {
		return "", err
	}

	defer conn.Close()

	statement, err := conn.Prepare(query)

	if err != nil {
		return "", err
	}

	defer statement.Close()

	result, err := statement.Exec()

	if err != nil {
		return "", err
	}

	serializedResult, _ := json.Marshal(result)

	return string(serializedResult), nil
}

// ExecuteQuery - Executes a query and returns the result set
func ExecuteQuery(query string) (*sql.Rows, error) {
	connString := fmt.Sprintf("server=%s;database=%s;user id=%s;password=%s;port=%d", *server, *database, *user, *password, *port)

	// Debug.Println("connString:%s\n", connString)

	conn, err := sql.Open("mssql", connString)

	if err != nil {
		logError(err, "Failed to connect to database.")
		return nil, err

	}

	defer conn.Close()

	statement, err := conn.Prepare(query)

	if err != nil {
		return nil, err
		// log.Fatal("Failed to query a trip: ", err.Error())
	}

	defer statement.Close()

	rows, err := statement.Query()

	if err != nil {
		return nil, err
		// log.Fatal("Error while running the query: ", err.Error())
	}

	return rows, nil
}

// FirstOrDefault - returns the first row of the result set.
func FirstOrDefault(query string) (*sql.Row, error) {
	connString := fmt.Sprintf("server=%s;database=%s;user id=%s;password=%s;port=%d", *server, *database, *user, *password, *port)

	if *debug {
		fmt.Printf("connString:%s\n", connString)
	}

	conn, err := sql.Open("mssql", connString)

	if err != nil {
		return nil, err
		// log.Fatal("Failed to connect to the database: ", err.Error())
	}

	defer conn.Close()

	statement, err := conn.Prepare(query)

	if err != nil {
		return nil, err
		// log.Fatal("Failed to query a trip: ", err.Error())
	}

	defer statement.Close()

	row := statement.QueryRow()

	return row, nil
}
