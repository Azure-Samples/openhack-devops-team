go clean
go build
go test ./tripsgo -run Unit -v -coverprofile=trips_coverage.out -covermode=count