using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System.Diagnostics;
using TripViewer.Models;
using TripViewer.Utility;

namespace TripViewer.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly IConfiguration Configuration;

        public HomeController(ILogger<HomeController> logger, IConfiguration configuration)
        {
            _logger = logger;
            Configuration = configuration;
        }

        public IActionResult Index()
        {
            TripViewerConfiguration tv = new TripViewerConfiguration
            {
                USER_ROOT_URL = Configuration.GetValue<string>("USER_ROOT_URL"),
                USER_JAVA_ROOT_URL = Configuration.GetValue<string>("USER_JAVA_ROOT_URL"),
                TRIPS_ROOT_URL = Configuration.GetValue<string>("TRIPS_ROOT_URL"),
                POI_ROOT_URL = Configuration.GetValue<string>("POI_ROOT_URL"),
                STAGING_USER_ROOT_URL = Configuration.GetValue<string>("STAGING_USER_ROOT_URL"),
                STAGING_USER_JAVA_ROOT_URL = Configuration.GetValue<string>("STAGING_USER_JAVA_ROOT_URL"),
                STAGING_TRIPS_ROOT_URL = Configuration.GetValue<string>("STAGING_TRIPS_ROOT_URL"),
                STAGING_POI_ROOT_URL = Configuration.GetValue<string>("STAGING_POI_ROOT_URL")
            };
            return View(tv);
        }

        public IActionResult Privacy()
        {
            return View();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
