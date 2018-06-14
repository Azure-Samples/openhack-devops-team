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

namespace IntegrationTests
{
    public class POIIntegrationTests: IClassFixture<CustomWebApplicationFactory<IntegrationTests.Startup>>
    {
        private readonly CustomWebApplicationFactory<IntegrationTests.Startup> _factory;

        public POIIntegrationTests(CustomWebApplicationFactory<IntegrationTests.Startup> factory)
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

            // Assert
            response.EnsureSuccessStatusCode(); // Status Code 200-299
            Assert.Equal("text/html; charset=utf-8",
                response.Content.Headers.ContentType.ToString());
        }
    }
}