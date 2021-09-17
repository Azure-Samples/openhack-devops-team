using Xunit;
using poi.Utility;
using System.Threading;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using Microsoft.Extensions.Primitives;
using System;
using System.ComponentModel.DataAnnotations;

namespace UnitTests.Utility
{

    public class POIConfigurationTests
    {

        private Dictionary<string, string> GetTestSettings()
        {
            string connectionStringTemplate = "Server=tcp:[SQL_SERVER],1433;Initial Catalog=[SQL_DBNAME];Persist Security Info=False;User ID=[SQL_USER];Password=[SQL_PASSWORD];MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
            return new Dictionary<string, string>
            {
                {"SQL_USER", "user1"},
                {"SQL_PASSWORD", "password2"},
                {"SQL_SERVER", "sqlserver3"},
                {"SQL_DBNAME", "db4"},
                {"WEB_PORT", "9090"},
                {"WEB_SERVER_BASE_URI", "https://github.com"},
                {"ConnectionStrings:myDrivingDB",connectionStringTemplate}
            };
        }

        private IConfiguration GetTestConfiguration()
        {
            var inMemorySettings = GetTestSettings();
            IConfiguration configuration = new ConfigurationBuilder()
                        .AddInMemoryCollection(inMemorySettings)
                        .Build();
            return configuration;
        }

        [Fact]
        public void GetConnectionString_ReturnsCS_WithCorrectValuesReplaced()
        {
            //arrange
            IConfiguration configuration = GetTestConfiguration();

            //act
            var connectionString = POIConfiguration.GetConnectionString(configuration);

            //assert
            var expectedConnectionString = "Server=tcp:sqlserver3,1433;Initial Catalog=db4;Persist Security Info=False;User ID=user1;Password=password2;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
            Assert.Equal(expectedConnectionString, connectionString);
        }


        [Fact]
        public void GetUri_Returns_DefailtUriAndPort_WhenNotInSettings()
        {
            //arrange
            IConfiguration configuration = GetTestConfiguration();

            //act
            var uri = POIConfiguration.GetUri(configuration);

            //assert
            var expectedUri = "https://github.com:9090";
            Assert.Equal(expectedUri, uri);
        }

        [Fact]
        public void GetUri_Returns_BaseUrlAndPortFromSettings()
        {
            //arrange
            var inMemorySettings = GetTestSettings();
            inMemorySettings.Remove("WEB_SERVER_BASE_URI");
            inMemorySettings.Remove("WEB_PORT");
            IConfiguration configuration = new ConfigurationBuilder()
                        .AddInMemoryCollection(inMemorySettings)
                        .Build();

            //act
            var uri = POIConfiguration.GetUri(configuration);

            //assert
            var expectedUri = "http://localhost:8080";
            Assert.Equal(expectedUri, uri);
        }
    }

}

