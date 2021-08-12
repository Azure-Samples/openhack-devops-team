using System;
using Microsoft.AspNetCore.Mvc;


namespace poi.Controllers
{
    [Produces("application/json")]
    [Route("api")]
    public class VersionController : ControllerBase
    {
        [Route("version/poi")]
        [HttpGet]
        [Produces("text/plain", Type = typeof(String))]
        public string GetVersion()
        {
            var version = Environment.GetEnvironmentVariable("APP_VERSION");
            return version ?? "default";
        }     
    }
}