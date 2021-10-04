using System;
using System.Collections.Generic;

namespace DeviceSim.DataObjects.Models
{
    public partial class Poisource
    {
        public string Id { get; set; }
        public string TripId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public int Poitype { get; set; }
        public string RecordedTimeStamp { get; set; }
    }
}
