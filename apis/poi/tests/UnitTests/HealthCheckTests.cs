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
            Assert.Equal("POI Service Healthcheck", new Healthcheck().Message);
            Assert.Equal("Healthy", new Healthcheck().Status);

        }

        [Fact]
        public void TempCheckTestPipeline()
        {
            Assert.Equal(0, 1);
        }
    }
}
