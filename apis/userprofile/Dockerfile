FROM node:8-alpine

COPY . /app

WORKDIR  /app

EXPOSE 8080

RUN npm install

RUN npm run test

CMD npm start

