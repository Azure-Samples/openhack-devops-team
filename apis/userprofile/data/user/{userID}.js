'use strict';
var Mockgen = require('../mockgen.js');
var TYPES = require('tedious').TYPES;
var queries = require('../queries');
/**
 * Operations on /user/{userID}
 */
module.exports = {
    /**
     * summary: 
     * description: Get a User Profile by ID
     * parameters: 
     * produces: 
     * responses: 200, default
     * operationId: userGET
     */
    get: {
        200: function (req, res, callback) {

            req.sql(queries.SELECT_USER_PROFILE_BY_ID)
                .param('user_profile_id', req.params.userID, TYPES.NVarChar)
                .into(res, '{}');
            callback;
          
        },
        default: function (req, res, callback) {
            /**
             * Using mock data generator module.
             * Replace this by factual data for the api.
             */
            Mockgen().responses({
                path: '/user/{userID}',
                operation: 'get',
                response: 'default'
            }, callback);
        }
    },
    /**
     * summary: 
     * description: Declares and creates a new profile
     * parameters: _profile
     * produces: 
     * responses: 201, default
     * operationId: userPOST
     */
    post: {
        201: function (req, res, callback) {
            
            req.sql(queries.INSERT_USER_PROFILE)
                .param('UserProfileJson', req.body, TYPES.NVarChar)
                .exec(res);
            callback;
        
        },
        default: function (req, res, callback) {
            /**
             * Using mock data generator module.
             * Replace this by actual data for the api.
             */
            Mockgen().responses({
                path: '/user/{userID}',
                operation: 'post',
                response: 'default'
            }, callback);
        }
    },
    /**
     * summary: 
     * description: Update User
     * parameters: 
     * produces: 
     * responses: 200, 404, default
     * operationId: updateUser
     */
    patch: {
        200: function (req, res, callback) {
 
            req.sql('EXEC UpdateProductFromJson @id, @json')
                .param('json', req.body, TYPES.NVarChar)
                .param('id', req.params.id, TYPES.Int)
                .exec(res);
            callback;
            
        },
        404: function (req, res, callback) {
            /**
             * Using mock data generator module.
             * Replace this by actual data for the api.
             */
            Mockgen().responses({
                path: '/user/{userID}',
                operation: 'patch',
                response: '404'
            }, callback);
        },
        default: function (req, res, callback) {
            /**
             * Using mock data generator module.
             * Replace this by actual data for the api.
             */
            Mockgen().responses({
                path: '/user/{userID}',
                operation: 'patch',
                response: 'default'
            }, callback);
        }
    },
    /**
     * summary: 
     * description: Delete User By ID
     * parameters: 
     * produces: 
     * responses: 204, 404, default
     * operationId: userDELETE
     */
    delete: {
        204: function (req, res, callback) {
            var tempmessage = '';
            var resmessage = tempmessage.concat('User profile ',req.params.userID,' deleted');
            req.sql(queries.DELETE_USER_PROFILE)
                .param('user_profile_id', req.params.userID, TYPES.NVarChar)
                .into(res, resmessage);
            callback;

        },
        404: function (req, res, callback) {
            /**
             * Using mock data generator module.
             * Replace this by actual data for the api.
             */
            Mockgen().responses({
                path: '/user/{userID}',
                operation: 'delete',
                response: '404'
            }, callback);
        },
        default: function (req, res, callback) {
            /**
             * Using mock data generator module.
             * Replace this by actual data for the api.
             */
            Mockgen().responses({
                path: '/user/{userID}',
                operation: 'delete',
                response: 'default'
            }, callback);
        }
    }
};
