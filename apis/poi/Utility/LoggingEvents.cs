using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;

namespace poi.Utility
{
    // You may need to install the Microsoft.AspNetCore.Http.Abstractions package into your project
    public class LoggingEvents
    {
        public const int Healthcheck = 1000;

        public const int GetAllPOIs = 2001;
        public const int GetPOIByID = 2002;
        public const int GetPOIByTripID = 2002;

    }

}
