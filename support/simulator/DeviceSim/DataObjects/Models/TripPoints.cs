using System;
using System.Collections.Generic;

namespace DeviceSim.DataObjects.Models
{
    public partial class TripPoints
    {
        public string Id { get; set; }
        public string TripId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public double Speed { get; set; }
        public DateTime RecordedTimeStamp { get; set; }
        public int Sequence { get; set; }
        public double Rpm { get; set; }
        public double ShortTermFuelBank { get; set; }
        public double LongTermFuelBank { get; set; }
        public double ThrottlePosition { get; set; }
        public double RelativeThrottlePosition { get; set; }
        public double Runtime { get; set; }
        public double DistanceWithMalfunctionLight { get; set; }
        public double EngineLoad { get; set; }
        public double MassFlowRate { get; set; }
        public double EngineFuelRate { get; set; }
        public string Vin { get; set; }
        public bool HasObddata { get; set; }
        public bool HasSimulatedObddata { get; set; }
        public byte[] Version { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset? UpdatedAt { get; set; }
        public bool Deleted { get; set; }

        public Trips Trip { get; set; }
    }
}
