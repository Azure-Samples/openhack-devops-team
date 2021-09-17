FROM node:8-alpine

COPY . /app

WORKDIR  /app

EXPOSE 8080

# docker build argument
#    This can be specified during the docker build step by adding " --build-arg build_version=<value>"
#    App version can be accessed via the uri path /api/version/user
#    https://vsupalov.com/docker-build-pass-environment-variables/
ARG build_version="userprofile default"
ENV APP_VERSION=$build_version 


RUN npm install

CMD npm start
