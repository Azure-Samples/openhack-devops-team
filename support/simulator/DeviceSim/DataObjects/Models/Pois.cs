using System;
using System.Collections.Generic;

namespace DeviceSim.DataObjects.Models
{
    public partial class Pois
    {
        public string Id { get; set; }
        public string TripId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public int Poitype { get; set; }
        public string RecordedTimeStamp { get; set; }
        public byte[] Version { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset? UpdatedAt { get; set; }
        public bool Deleted { get; set; }
        public DateTime Timestamp { get; set; }
    }
}
