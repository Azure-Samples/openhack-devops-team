'use strict';
var dataProvider = require('../../data/healthcheck/user.js');
/**
 * Operations on /healthcheck/user
 */
module.exports = {
    /**
     * summary: 
     * description: Returns healthcheck for systems looking to ensure API is up and operational
     * parameters: 
     * produces: 
     * responses: 200, default
     */
    get: function (req, res, next) {
        /**
         * Get the data for response 200
         * For response `default` status 200 is used.
         */
        var status = 200;
        var provider = dataProvider['get']['200'];
        provider(req, res, function (err, data) {
            if (err) {
                next(err);
                return;
            }
            res.status(status).send(data && data.responses);
        });
    }
};
