
using System.IO;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Azure.WebJobs.Host;
using Newtonsoft.Json;
using System.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using MyDriving.ServiceObjects;
using System;

namespace MyDriving.POIService.v2
{
    public static class POIService
    {
        [FunctionName("GetAllPOIs")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)]HttpRequest req, TraceWriter log, ExecutionContext context)
        {
            try
            {
                log.Info("Starting azure function executions @" + DateTime.Now.ToString());

                IConfiguration funcConfiguration;

                string tripId = req.Query["tripId"];

                var builder = new ConfigurationBuilder()
                    .SetBasePath(context.FunctionAppDirectory)
                    .AddJsonFile("appSettings.json", optional: false, reloadOnChange: true)
                    .AddEnvironmentVariables();

                funcConfiguration = builder.Build();

                var SQL_USER = funcConfiguration.GetSection("SQL_USER").Value;
                var SQL_PASSWORD = funcConfiguration.GetSection("SQL_PASSWORD").Value;
                var SQL_SERVER = funcConfiguration.GetSection("SQL_SERVER").Value;
                var SQL_DBNAME = funcConfiguration.GetSection("SQL_DBNAME").Value;

                var connectionString = funcConfiguration["ConnectionStrings:myDrivingDB"];

                connectionString = connectionString.Replace("[SQL_USER]", SQL_USER);
                connectionString = connectionString.Replace("[SQL_PASSWORD]", SQL_PASSWORD);
                connectionString = connectionString.Replace("[SQL_SERVER]", SQL_SERVER);
                connectionString = connectionString.Replace("[SQL_DBNAME]", SQL_DBNAME);

                using (var sqlConn = new SqlConnection(connectionString))
                {
                    log.Info("Connecting to database");

                    sqlConn.Open();
                    
                    string query = $"SELECT Id, Deleted, Latitude, Longitude, POIType, Timestamp, TripId FROM POIs WHERE TripId = '{tripId}'";

                    log.Info("Executing SQL Query: " + query);

                    var sqlCommand = new SqlCommand(query, sqlConn);

                    var rows = sqlCommand.ExecuteReader(System.Data.CommandBehavior.CloseConnection);

                    if (!rows.HasRows)
                    {
                        log.Info("There are no POIs for this Trip.");
                        return new BadRequestObjectResult("There are no POIs for this Trip.");
                    }
                    List<POI> poiList = new List<POI>();

                    while (rows.Read())
                    {
                        poiList.Add(new POI
                        {
                            Id = rows["Id"].ToString(),
                            Deleted = bool.Parse(rows["Deleted"].ToString()),
                            Latitude = double.Parse(rows["Latitude"].ToString()),
                            Longitude = double.Parse(rows["Longitude"].ToString()),
                            POIType = rows["POIType"].ToString().Equals("HardAcceleration") ? POIType.HardAcceleration : POIType.HardBrake,
                            Timestamp = DateTime.Parse(rows["Timestamp"].ToString()),
                            TripId = rows["TripId"].ToString()
                        });
                    }

                    rows.Close();

                    var poisSerialized = JsonConvert.SerializeObject(poiList);

                    log.Info("Data returned: " + poisSerialized);

                    return new OkObjectResult(poisSerialized);
                }
            }
            catch (Exception exception)
            {
                log.Info(exception.StackTrace);

                return new OkObjectResult(new {
                    StackTrace = exception.StackTrace,
                    Message = exception.Message
                });
            }
        }
    }
}