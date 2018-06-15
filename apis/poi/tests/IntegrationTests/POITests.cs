using System;
using Xunit;
using poi.Controllers;
using poi.Models;
using poi;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.AspNetCore.TestHost;
using Microsoft.Extensions.DependencyInjection;
using Newtonsoft.Json;

namespace IntegrationTests
{
    public class POIIntegrationTests: IClassFixture<CustomWebApplicationFactory<poi.Startup>>
    {
        private readonly CustomWebApplicationFactory<poi.Startup> _factory;

        public POIIntegrationTests(CustomWebApplicationFactory<poi.Startup> factory)
        {
            _factory = factory;
        }

        [Theory]
        [InlineData("/api/poi/")]
        public async Task Get_EndpointsReturnSuccessAndCorrectContentType(string url)
        {
            // Arrange
            var client = _factory.CreateClient(
                new WebApplicationFactoryClientOptions{
                    BaseAddress = new Uri("http://localhost:8080")
                }
            );

            // Act
            var response = await client.GetAsync(url);


            // Asserts (Check status code, content type and actual response)
            response.EnsureSuccessStatusCode(); // Status Code 200-299
            Assert.Equal("application/json; charset=utf-8",
                response.Content.Headers.ContentType.ToString());

            //deserialize response to poi list
            List<POI> pois = JsonConvert.DeserializeObject<List<POI>>(
                await response.Content.ReadAsStringAsync());

            //Check that 3 pois are returned
            Assert.Equal(3,
            pois.Count);
        }
    }
}