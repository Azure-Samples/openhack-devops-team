FROM golang:1.11.0 AS gobuild

WORKDIR /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips

COPY . .

ENV GO111MODULE=on

RUN go mod vendor

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:3.7 AS gorun

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
WEB_PORT="80" \
WEB_SERVER_BASE_URI="http://0.0.0.0" \
DOCS_URI="http://localhost" \
DEBUG_LOGGING="false"

WORKDIR /app

RUN apk add --update \
  ca-certificates

COPY --from=gobuild /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips/main .
COPY --from=gobuild /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips/api ./api/

CMD ["./main"]
