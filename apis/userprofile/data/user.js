'use strict';
var Mockgen = require('./mockgen.js');
var queries = require('./queries');
/**
 * Operations on /user
 */
module.exports = {
    /**
     * summary: 
     * description: List all user profiles
     * parameters: 
     * produces: 
     * responses: 200, default
     * operationId: getAllUsers
     */
    get: {
        200: function (req, res, callback) {
            
            req.sql(queries.SELECT_USER_PROFILES)
                .into(res);
            callback;
        
        },
        default: function (req, res, callback) {

            Mockgen().responses({
                path: '/user',
                operation: 'get',
                response: 'default'
            }, callback);
        }
    }
};
