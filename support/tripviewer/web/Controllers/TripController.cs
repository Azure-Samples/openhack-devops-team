using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;
using Simulator.DataObjects;
using Simulator.DataStore.Stores;
using TripViewer.Utility;


namespace TripViewer.Controllers
{
    public class TripController : Controller
    {
        private readonly IConfiguration Configuration;
        private readonly IHttpClientFactory _clientFactory;
        public TripController(IHttpClientFactory clientFactory, IConfiguration configuration)
        {
            _clientFactory = clientFactory;
            Configuration = configuration;
        }
        [HttpGet]
        public IActionResult Index()
        {
            var teamendpoint = Configuration.GetValue<string>("TRIPS_ROOT_URL");
            var bingMapsKey = Configuration.GetValue<string>("BING_MAPS_KEY");

            //Get trips
            TripStore t = new TripStore(_clientFactory, teamendpoint);
            List<Trip> trips = t.GetItemsAsync().Result;
            //Get Last Trip
            var last = trips.Max(trip => trip.RecordedTimeStamp);
            var tlast = from Trip latest in trips
                        where latest.RecordedTimeStamp == last
                        select latest;
            //Get TripPoints
            TripPointStore tps = new TripPointStore(_clientFactory,teamendpoint);
            List<TripPoint> tripPoints = tps.GetItemsAsync(tlast.First()).Result;
            
            ViewData["MapKey"] = bingMapsKey;
            return View(tripPoints);
        }

        public PartialViewResult RenderMap()
        {
            var teamendpoint = Configuration.GetValue<string>("TRIPS_ROOT_URL");
            //Get trips
            TripStore t = new TripStore(_clientFactory, teamendpoint);
            List<Trip> trips = t.GetItemsAsync().Result;
            //Get Last Trip
            var last = trips.Max(trip => trip.RecordedTimeStamp);
            var tlast = from Trip latest in trips
                        where latest.RecordedTimeStamp == last
                        select latest;
            //Get TripPoints
            TripPointStore tps = new TripPointStore(_clientFactory, teamendpoint);
            List<TripPoint> tripPoints = tps.GetItemsAsync(tlast.First()).Result;

            
            return PartialView(tripPoints);
        }
    }
}