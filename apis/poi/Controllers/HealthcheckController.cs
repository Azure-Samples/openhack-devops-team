using System;
using Microsoft.AspNetCore.Mvc;
using System.Linq;
using System.Collections.Generic;
using poi.Models;
using poi.Data;
using Newtonsoft.Json;


namespace poi.Controllers
{
    [Produces("application/json")]
    [Route("api/[controller]")]
    public class HealthCheckController : ControllerBase
    {

        [HttpGet]
        [Produces("application/json", Type = typeof(Healthcheck))]
        public IActionResult Get()
        {
            string response = JsonConvert.SerializeObject(new Healthcheck());
            return Ok(response);
        }
    }

}