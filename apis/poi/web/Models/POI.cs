// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace poi.Models
{

    public enum POIType
    {
        HardAcceleration = 1,
        HardBrake = 2
    }

    public class POI : BaseDataObject
    {
        public string TripId { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public POIType PoiType { get; set; }
        public DateTime Timestamp { get; set; }
        public bool Deleted { get; set; }
    }
}