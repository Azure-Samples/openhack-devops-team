using System;
using System.Collections.Generic;

namespace DeviceSim.DataObjects.Models
{
    public partial class Trips
    {
        public Trips()
        {
            TripPoints = new HashSet<TripPoints>();
            //Points = new List<TripPoints>();
        }

        public string Id { get; set; }
        public string Name { get; set; }
        public string UserId { get; set; }
        public DateTime RecordedTimeStamp { get; set; }
        public DateTime EndTimeStamp { get; set; }
        public int Rating { get; set; }
        public bool IsComplete { get; set; }
        public bool HasSimulatedObddata { get; set; }
        public double AverageSpeed { get; set; }
        public double FuelUsed { get; set; }
        public long HardStops { get; set; }
        public long HardAccelerations { get; set; }
        public string MainPhotoUrl { get; set; }
        public double Distance { get; set; }
        public byte[] Version { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset? UpdatedAt { get; set; }
        public bool Deleted { get; set; }

        public ICollection<TripPoints> TripPoints { get; set; }
    }
}
