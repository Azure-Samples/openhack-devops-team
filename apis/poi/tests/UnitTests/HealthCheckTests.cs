using System;
using Xunit;
using poi.Models;

namespace UnitTests
{
    public class HealthCheckUnitTests
    {
        [Fact]
        public void HealthCheckTestModel()
        {
            Assert.Equal("POI Service Healthcheck V2", new Healthcheck().Message);
            Assert.Equal("I am healthy", new Healthcheck().Status);

        }
    }
}
