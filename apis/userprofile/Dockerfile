FROM node:8-alpine

COPY . /app

WORKDIR  /app

EXPOSE 8080

RUN npm install

RUN npm test

RUN cat reports/userprofile-report.xml

CMD npm start