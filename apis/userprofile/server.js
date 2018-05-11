'use strict';

var Http = require('http');
var Express = require('express');
var BodyParser = require('body-parser');
var Swaggerize = require('swaggerize-express');
var Path = require('path');
var tediousExpress = require('express4-tedious');
var sqlConfig = require('./config/sqlConfig');

var App = Express();

var Server = Http.createServer(App);

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
    docspath: '/docs/user',
    handlers: Path.resolve('./handlers')
}));


Server.listen(8080, function () {
    App.swagger.api.host = this.address().address + ':' + this.address().port;
    /* eslint-disable no-console */
    console.log('App running on %s:%d', this.address().address, this.address().port);
    /* eslint-disable no-console */
});
