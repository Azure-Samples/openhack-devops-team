using System;
using System.Collections.Generic;

namespace DeviceSim.DataObjects.Models
{
    public partial class UserProfiles
    {
        public UserProfiles()
        {
            Devices = new HashSet<Devices>();
        }

        public string Id { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string UserId { get; set; }
        public string ProfilePictureUri { get; set; }
        public int Rating { get; set; }
        public int Ranking { get; set; }
        public double TotalDistance { get; set; }
        public long TotalTrips { get; set; }
        public long TotalTime { get; set; }
        public long HardStops { get; set; }
        public long HardAccelerations { get; set; }
        public double FuelConsumption { get; set; }
        public double MaxSpeed { get; set; }
        public byte[] Version { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset? UpdatedAt { get; set; }
        public bool Deleted { get; set; }

        public ICollection<Devices> Devices { get; set; }
    }
}
