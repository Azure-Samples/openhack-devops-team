'use strict';

require('dotenv').config()

var Http = require('http');
var Express = require('express');
var BodyParser = require('body-parser');
var Swaggerize = require('swaggerize-express');
var Path = require('path');
var tediousExpress = require('express4-tedious');
var sqlConfig = require('./config/sqlConfig');
var morgan = require('morgan');
const swaggerUi = require('swagger-ui-express');
const swaggerDocument = require('./config/swagger.json');

var App = Express();

var Server = Http.createServer(App);

var logger = morgan(':remote-addr [:date[web]] :method :url HTTP/:http-version :status :res[content-length] :referrer :user-agent :response-time ms');

App.use(logger);

App.use(function (req, res, next) {
    req.sql = tediousExpress(sqlConfig);
    next();
});

App.use(BodyParser.json());
App.use(BodyParser.urlencoded({
    extended: true
}));

App.use(Swaggerize({
    api: Path.resolve('./config/swagger.json'),
    handlers: Path.resolve('./handlers')
}));

App.use('/api/docs/user', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

Server.listen(8080, function () {
    App.swagger.api.host = this.address().address + ':' + this.address().port;
    /* eslint-disable no-console */
    console.log('App running on %s:%d', this.address().address, this.address().port);
    /* eslint-disable no-console */
});
