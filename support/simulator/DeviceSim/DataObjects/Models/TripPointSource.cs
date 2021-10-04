using System;
using System.Collections.Generic;

namespace DeviceSim.DataObjects.Models
{
    public partial class TripPointSource
    {
        public string Tripid { get; set; }
        public string Userid { get; set; }
        public string Name { get; set; }
        public string Trippointid { get; set; }
        public decimal Lat { get; set; }
        public decimal Lon { get; set; }
        public int Speed { get; set; }
        public string Recordedtimestamp { get; set; }
        public int Sequence { get; set; }
        public int Enginerpm { get; set; }
        public int Shorttermfuelbank { get; set; }
        public int Longtermfuelbank { get; set; }
        public int Throttleposition { get; set; }
        public int Relativethrottleposition { get; set; }
        public int Runtime { get; set; }
        public int Distancewithmil { get; set; }
        public int Engineload { get; set; }
        public int Mafflowrate { get; set; }
        public string Outsidetemperature { get; set; }
        public int Enginefuelrate { get; set; }
        public int? Field21 { get; set; }
    }
}
