using Xunit;
using poi.Controllers;
using System;
using Microsoft.EntityFrameworkCore;
using poi.Data;
using poi.Models;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;

namespace UnitTests.ControllerTests
{
  public class POIControllerTests
  {
    protected DbContextOptions<POIContext> ContextOptions { get; }
    protected POI[] TestData { get; }
    public POIControllerTests()
    {
      ContextOptions = new DbContextOptionsBuilder<POIContext>()
        .UseInMemoryDatabase("POIDatabase")
        .Options;
      TestData = POIFixture.GetData();
      Seed();
    }

    private void Seed()
    {
      using (var context = new POIContext(ContextOptions))
      {
        context.Database.EnsureDeleted();
        context.Database.EnsureCreated();

        context.AddRange(TestData);
        context.SaveChanges();
      }
    }

    [Fact]
    public void GetAll_Returns_AllItems()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var points = controller.GetAll().ToList();

        //assert  
        Assert.Equal(TestData.Length, points.Count);
      }
    }

    [Fact]
    public void GetById_WithValidId_Returns_SuccessStatus()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var point = TestData.FirstOrDefault();

        var result = controller.GetById(point.Id);
        var okResult = result as OkObjectResult;

        //assert  
        Assert.IsType<OkObjectResult>(result);
        Assert.NotNull(okResult);
        Assert.Equal(200, okResult.StatusCode);
      }
    }

    [Fact]
    public void GetById_WithValidId_Returns_CorrectPoint()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var point = TestData.FirstOrDefault();

        var result = controller.GetById(point.Id);
        var okResult = result as OkObjectResult;
        var poiResult = okResult.Value as POI;

        //assert  
        Assert.NotNull(okResult.Value);
        Assert.Equal(point.TripId, poiResult.TripId);
        Assert.Equal(point.Latitude, poiResult.Latitude);
        Assert.Equal(point.Longitude, poiResult.Longitude);
        Assert.Equal(point.PoiType, poiResult.PoiType);
        Assert.Equal(point.Deleted, poiResult.Deleted);
        Assert.Equal(point.Timestamp, poiResult.Timestamp);
      }
    }

    [Fact]
    public void GetById_WithInvalidId_Returns_NotFoundResult()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var point = TestData.FirstOrDefault();

        var result = controller.GetById("fake_id");

        //assert  
        Assert.NotNull(result);
        Assert.IsType<NotFoundResult>(result);

        var notFoundResult = result as NotFoundResult;
        Assert.Equal(404, notFoundResult.StatusCode);
      }
    }

    [Fact]
    public void GetByTripId_WithValidTripId_Returns_SuccessStatus()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var point = TestData.FirstOrDefault();

        var result = controller.GetByTripId(point.TripId);
        var okResult = result as OkObjectResult;

        //assert  
        Assert.IsType<OkObjectResult>(result);
        Assert.NotNull(okResult);
        Assert.Equal(200, okResult.StatusCode);
      }
    }

    [Fact]
    public void GetByTripId_WithValidTripId_Returns_CorrectPoint()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var point = TestData.FirstOrDefault();

        var result = controller.GetByTripId(point.TripId);
        var okResult = result as OkObjectResult;
        var poiResults = okResult.Value as List<POI>;
        var poiResult = poiResults.FirstOrDefault();

        //assert  
        Assert.NotNull(okResult.Value);
        Assert.Equal(point.TripId, poiResult.TripId);
        Assert.Equal(point.Latitude, poiResult.Latitude);
        Assert.Equal(point.Longitude, poiResult.Longitude);
        Assert.Equal(point.PoiType, poiResult.PoiType);
        Assert.Equal(point.Deleted, poiResult.Deleted);
        Assert.Equal(point.Timestamp, poiResult.Timestamp);
      }
    }

    [Fact]
    public void GetByTripId_WithInvalidTripId_Returns_OkObjectResult()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var point = TestData.FirstOrDefault();

        var result = controller.GetByTripId("fake_trip_id");

        //assert  
        Assert.NotNull(result);
        Assert.IsType<OkObjectResult>(result);

        var poiResult = result as OkObjectResult;
        Assert.Equal(200, poiResult.StatusCode);
      }
    }

    [Fact]
    public void GetByTripId_WithInvalidTripId_Returns_EmptyList()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);

        //act
        var point = TestData.FirstOrDefault();

        var result = controller.GetByTripId("fake_trip_id");

        //assert  
        var poiResult = result as OkObjectResult;
        var poiList =  poiResult.Value as List<POI>;
        Assert.Empty(poiList);
      }
    }

    [Fact]
    public void CreatePoi_WithValidPoint_AddsPointToDb()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);
        var point = new POI{
          TripId = "8675309",
          Latitude=35.6262904,
          Longitude=139.780985,
          PoiType = POIType.HardBrake,
          Timestamp = DateTime.Now          
        };
        //act
        controller.CreatePoi(point);

        var response = controller.GetByTripId("8675309") as OkObjectResult;
        var results = response.Value as List<POI>;
        var result = results.FirstOrDefault();
        
        //assert  
        Assert.NotNull(result);
        Assert.Equal(point.Latitude,result.Latitude);
        Assert.Equal(point.Longitude,result.Longitude);
        Assert.Equal(point.TripId,result.TripId);
      }
    }
   
    [Fact]
    public void CreatePoi_WithValidPoint_AddGuidToPOI()
    {
      using (var context = new POIContext(ContextOptions))
      {
        //arrange
        var controller = new POIController(context);
        var point = new POI{
          TripId = "8675309",
          Latitude=35.6262904,
          Longitude=139.780985,
          PoiType = POIType.HardBrake,
          Timestamp = DateTime.Now          
        };
        //act
        controller.CreatePoi(point);

        var response = controller.GetByTripId("8675309") as OkObjectResult;
        var results = response.Value as List<POI>;
        var result = results.FirstOrDefault();
        
        //assert  
        Assert.NotNull(result);
        Assert.Equal(point.Latitude,result.Latitude);
        Assert.Equal(point.Longitude,result.Longitude);
        Assert.Equal(point.TripId,result.TripId);
      }      
    }    


 }
}

