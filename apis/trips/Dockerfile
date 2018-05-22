FROM golang:1.10.1 AS gobuild

RUN go get -t github.com/Azure-Samples/openhack-devops-team/apis/trips

WORKDIR /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:3.7 AS gorun

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
WEB_PORT="8080" \
WEB_SERVER_BASE_URI="http://localhost" \
DEBUG_LOGGING="false"

WORKDIR /app

RUN apk add --update \
  ca-certificates

COPY --from=gobuild /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips/main .
COPY --from=gobuild /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips/api ./api/

CMD ["./main"]
