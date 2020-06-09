'use strict';

/**
 * Operations on /version/user
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
      let status = 200;
      let version  = process.env.APP_VERSION;
      res.set('Content-Type', 'text/plain');
      res.status(status).send(version);
    }
};
