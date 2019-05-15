'use strict';
var Mockgen = require('../mockgen.js');
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
     * operationId: 
     */
    get: {
        200: function (req, res, callback) {
            res.json({
                message: 'healthcheck v2',
                status: 'I am still healthy.'
            });
            callback;
        },
        default: function (req, res, callback) {
            /**
             * Using mock data generator module.
             * Replace this by actual data for the api.
             */
            Mockgen().responses({
                path: '/healthcheck/user',
                operation: 'get',
                response: 'default'
            }, callback);
        }
    }
};
