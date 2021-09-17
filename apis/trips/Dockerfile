FROM golang:1.14.2 AS gobuild

WORKDIR /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips

COPY . .

RUN go get

RUN CGO_ENABLED=0 GOOS=linux go build -o main .

FROM alpine:3.8 AS gorun

# docker build argument
#    This can be specified during the docker build step by adding " --build-arg build_version=<value>"
#    App version can be accessed via the uri path /api/version/trips
#    https://vsupalov.com/docker-build-pass-environment-variables/
ARG build_version="trips default"

ENV SQL_USER="YourUserName" \
SQL_PASSWORD="changeme" \
SQL_SERVER="changeme.database.windows.net" \
SQL_DBNAME="mydrivingDB" \
WEB_PORT="80" \
WEB_SERVER_BASE_URI="http://0.0.0.0" \
DOCS_URI="http://localhost" \
DEBUG_LOGGING="false" \
APP_VERSION=$build_version 

WORKDIR /app

RUN apk add --update \
  ca-certificates

COPY --from=gobuild /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips/main .
COPY --from=gobuild /go/src/github.com/Azure-Samples/openhack-devops-team/apis/trips/api ./api/

CMD ["./main"]
