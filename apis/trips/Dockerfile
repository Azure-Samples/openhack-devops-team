FROM golang:1.10.1 AS gobuild

RUN go get -t github.com/Azure-Samples/openhack-devops/src/MobileAppServiceV2/TripService

WORKDIR /go/src/github.com/Azure-Samples/openhack-devops/src/MobileAppServiceV2/TripService

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:3.7 AS gorun

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB"

WORKDIR /app

RUN apk add --update \
  ca-certificates

COPY --from=gobuild /go/src/github.com/Azure-Samples/openhack-devops/src/MobileAppServiceV2/TripService/main .

CMD ["./main"]