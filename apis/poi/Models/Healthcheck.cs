using System;
namespace poi.Models
{
    public class Healthcheck
    {
        public Healthcheck()
        {
            Message = "POI Service Healthcheck";
            Status = "Healthy";
        }

        public string Message {get;set;}
        public string Status { get; set; }
    }
}
