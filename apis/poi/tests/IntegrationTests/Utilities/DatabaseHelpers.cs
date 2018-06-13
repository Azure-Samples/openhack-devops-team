using System;
using System.Collections.Generic;
using poi.Data;
using poi.Models;

namespace IntegrationTests.Utilities {
    public static class DatabaseHelpers {
        public static void InitializeDbForTests (POIContext db) {
            db.POIs.AddRange (GetSeedingPois ());
            db.SaveChanges ();
        }

        public static List<POI> GetSeedingPois () {
            return new List<POI> () {
                new POI {
                    TripId = Guid.NewGuid ().ToString (),
                        Latitude = 0,
                        Longitude = 0,
                        PoiType = POIType.HardAcceleration,
                        Timestamp = DateTime.Now,
                        Deleted = false
                },
                new POI {
                    TripId = Guid.NewGuid ().ToString (),
                        Latitude = 0,
                        Longitude = 0,
                        PoiType = POIType.HardBrake,
                        Timestamp = DateTime.Now,
                        Deleted = false
                },
                new POI {
                    TripId = Guid.NewGuid ().ToString (),
                        Latitude = 0,
                        Longitude = 0,
                        PoiType = POIType.HardAcceleration,
                        Timestamp = DateTime.Now,
                        Deleted = false
                }
            };
        }
    }
}