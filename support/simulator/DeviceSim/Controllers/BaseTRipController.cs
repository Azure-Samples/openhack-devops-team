using DeviceSim.DataObjects.Models;
using DeviceSim.Helpers;

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using System.Threading.Tasks;


namespace DeviceSim.Controllers
{
    public class BaseTripController
    {
        protected internal mydrivingDBContext Ctx { get; set; }
        protected internal List<TripPointSource> TripPointSourceInfo { get; set; }
        protected internal List<Poisource> TripPOIsource { get; set; }



        public BaseTripController(DBConnectionInfo dBConnectionInfo)
        {
            Ctx = new mydrivingDBContext(dBConnectionInfo);
            //Select Random Trip 
            GetSampleTrip();
            //Default Constructor
        }

        private void GetSampleTrip()
        {
            Random r = new Random();
            //Get Sample Trip Names
            List<string> tripNames = Ctx.TripPointSource.Select(p => p.Name).Distinct().ToList();
            //Choose Random Trip
            var tName = tripNames.ElementAt(r.Next(0, tripNames.Count));

            //Get Source TripPoints for Random Trip
            TripPointSourceInfo = Ctx.TripPointSource.Where(p => p.Name == tName).ToList();
            //Get Source POIs for Random Trip
            TripPOIsource = Ctx.Poisource.Where(p => p.TripId == (TripPointSourceInfo.FirstOrDefault().Name)).ToList();
            //Console.WriteLine($"Sample Trip Selected: {tName}");

        }


    }
}
