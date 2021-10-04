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
    public class EFTripController : BaseTripController
    {
        #region Variables


           
        private Trips CurrentTrip;
       
        //private mydrivingDBContext ctx;
        //private List<TripPointSource> tripInfo;
        //private List<Poisource> tripPOIsource;




        #endregion

        #region Constructor

        //Create Trips from Data in the Database
        public EFTripController(DBConnectionInfo dBConnectionInfo):base(dBConnectionInfo)
        {
            
        }
        #endregion

        #region Public Methods

        public async Task CreateTrip()
        {
            //1 - Initialize Trip
            CurrentTrip = new Trips()
            {
                RecordedTimeStamp = DateTime.UtcNow,
                Name = $"Trip {DateTime.Now}",
                Id = Guid.NewGuid().ToString(),
                UserId = "Hacker 1"
            };

            CreateTripPoints();

            //TODO : Do proper Distance Calculation and Add a method to determine Rating
            CurrentTrip.EndTimeStamp = CurrentTrip.TripPoints.Last<TripPoints>().RecordedTimeStamp;
            CurrentTrip.Rating = 90;
            //TODO : DO BingMaps Call to determine distance
            CurrentTrip.Distance = 5.95;

            //Get Trip POIs and Update Trip Summary Information 
            CreateTripPois();
            //Update Driver Profile with Trip Data
            UpdateUserProfile();

            //Add trips to DB Instance
            await Ctx.Trips.AddAsync(CurrentTrip);
            
            
        }
        public async Task<bool> SaveChangesAsync()
        {

            try
            {
                await Ctx.SaveChangesAsync();
                Ctx.Dispose();
                return true;
            }
            catch (Exception)
            {
                return false;
            }

        }


        #endregion

        #region Private Methods
        //private void GetSampleTrip()
        //{   
        //    Random r = new Random();
        //    //Get Sample Trip Names
        //    List<string> tripNames = ctx.TripPointSource.Select(p => p.Name).Distinct().ToList();
        //    //Choose Random Trip
        //    var tName = tripNames.ElementAt(r.Next(0, tripNames.Count));

        //    //Get Source TripPoints for Random Trip
        //    tripInfo = ctx.TripPointSource.Where(p => p.Name == tName).ToList();
        //    //Get Source POIs for Random Trip
        //    tripPOIsource = ctx.Poisource.Where(p => p.TripId == (tripInfo.FirstOrDefault().Name)).ToList();
        //    //Console.WriteLine($"Sample Trip Selected: {tName}");
           
        //}

        private void CreateTripPois()
        {
            List<Pois> poiList = Ctx.Pois.Where(p => p.TripId == CurrentTrip.Id).ToList<Pois>();
           
            //Generate POIs from Source
            foreach (var sPOI in TripPOIsource)
            {
                poiList.Add(new Pois
                {
                    Id = Convert.ToString(Guid.NewGuid()), //New Guid
                    TripId = CurrentTrip.Id, //Current Trips Id
                    Latitude = sPOI.Latitude,
                    Longitude = sPOI.Longitude,
                    Poitype = sPOI.Poitype,
                    RecordedTimeStamp = DateTime.Now.ToLongTimeString()
                });
            }

            //Add POI's to Database Context
            Ctx.Pois.AddRangeAsync(poiList);

            CurrentTrip.HardStops = poiList.Where(p => p.Poitype == 2).Count();
            CurrentTrip.HardAccelerations = poiList.Where(p => p.Poitype == 1).Count();
        }

        private void UpdateUserProfile()
        {
            try
            {
                UserProfiles up = Ctx.UserProfiles
                                .Where(user => user.UserId == CurrentTrip.UserId)
                                .SingleOrDefault();


                up.TotalTrips++;
                up.TotalDistance += CurrentTrip.Distance;
                up.HardStops += CurrentTrip.HardStops;
                up.HardAccelerations += CurrentTrip.HardAccelerations;
            }
            catch (Exception ex)
            {
                
                Console.WriteLine($"Unable to Update User Profile. Ensure that the  Trip UserProfile Matches with records in the database for Hacker 1, for more information see: {ex.Message}.");

            }
        }

        private void CreateTripPoints()
        {
            
            try
            {
               
                foreach (var tps in TripPointSourceInfo)
                {
                    TripPoints _tripPoint = new TripPoints()
                    {
                        TripId = CurrentTrip.Id,
                        Id = Guid.NewGuid().ToString(),
                        Latitude = Convert.ToDouble(tps.Lat),
                        Longitude = Convert.ToDouble(tps.Lon),
                        Speed = Convert.ToDouble(tps.Speed),
                        RecordedTimeStamp = Convert.ToDateTime(tps.Recordedtimestamp),
                        Sequence = Convert.ToInt32(tps.Sequence),
                        Rpm = Convert.ToDouble(tps.Enginerpm),
                        ShortTermFuelBank = Convert.ToDouble(tps.Shorttermfuelbank),
                        LongTermFuelBank = Convert.ToDouble(tps.Longtermfuelbank),
                        ThrottlePosition = Convert.ToDouble(tps.Throttleposition),
                        RelativeThrottlePosition = Convert.ToDouble(tps.Relativethrottleposition),
                        Runtime = Convert.ToDouble(tps.Runtime),
                        DistanceWithMalfunctionLight = Convert.ToDouble(tps.Distancewithmil),
                        EngineLoad = Convert.ToDouble(tps.Engineload),
                        MassFlowRate = Convert.ToDouble(tps.Mafflowrate),
                        EngineFuelRate = Convert.ToDouble(tps.Enginefuelrate)

                    };
                    CurrentTrip.TripPoints.Add(_tripPoint);
                }



                //Update Time Stamps to current date and times before sending to IOT Hub
                UpdateTripPointTimeStamps(CurrentTrip);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Could not create/update Trip Points. For more detail see: {ex.Message}.");
            }
        }

        private  void UpdateTripPointTimeStamps(Trips trip)
        {
            try
            {
                //Sort Trip Points By Sequence Number
                CurrentTrip.TripPoints = CurrentTrip.TripPoints.OrderBy(p => p.Sequence).ToList();

                List<timeInfo> timeToAdd = new List<timeInfo>();
                System.TimeSpan tDiff;

                //Create a Variable to Track the Time Range as it Changes
                System.DateTime runningTime = CurrentTrip.RecordedTimeStamp;

                //Calculate the Difference in time between Each Sequence Item 
                for (int currentTripPoint = (CurrentTrip.TripPoints.Count - 1); currentTripPoint > -1; currentTripPoint--)
                {
                    if (currentTripPoint > 0)
                    {
                        tDiff = CurrentTrip.TripPoints.ElementAt(currentTripPoint).RecordedTimeStamp
                              - CurrentTrip.TripPoints.ElementAt(currentTripPoint - 1).RecordedTimeStamp;
                        timeToAdd.Add(new timeInfo() { evtSeq = CurrentTrip.TripPoints.ElementAt(currentTripPoint).Sequence, tSpan = tDiff });

                    }

                }

                //Sort List in order to Add time to Trip Points
                timeToAdd = timeToAdd.OrderBy(s => s.evtSeq).ToList();
                //Update Trip Points

                for (int currentTripPoint = 1, timeToAddCollIdx = 0; currentTripPoint < CurrentTrip.TripPoints.Count; currentTripPoint++, timeToAddCollIdx++)
                {
                    runningTime = runningTime.Add(timeToAdd[timeToAddCollIdx].tSpan);
                    CurrentTrip.TripPoints.ElementAt(currentTripPoint).RecordedTimeStamp = runningTime;
                }

                // Update Initial Trip Point
                CurrentTrip.TripPoints.ElementAt(0).RecordedTimeStamp = CurrentTrip.RecordedTimeStamp;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Could not update Trip Time Stamps from Samples. for more info see:{ex.Message}.");
            }
        }
        #endregion

    }


    public struct timeInfo
    {
        public int evtSeq;
        public TimeSpan tSpan;
    }
}
