using System;
using poi.Models;

public class POIFixture
{
  public static POI[] GetData()
  {
    return new POI[]
         {
            new POI{
            TripId = "1234",
            Latitude = 30.021530,
            Longitude = 31.071170,
            PoiType = POIType.HardAcceleration,
            Timestamp = DateTime.Now,
            Deleted = false
          },
          new POI{
            TripId = "5678",
            Latitude = 12.0075934,
            Longitude = 120.200048,
            PoiType = POIType.HardAcceleration,
            Timestamp = DateTime.Now,
            Deleted = false
          }
         };
  }
}