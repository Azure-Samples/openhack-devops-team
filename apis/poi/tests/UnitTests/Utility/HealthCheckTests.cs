using Xunit;
using poi.Controllers;
using System;
using Microsoft.EntityFrameworkCore;
using poi.Data;
using poi.Models;
using System.Linq;
using Microsoft.AspNetCore.Mvc;
using System.Collections.Generic;
using poi.Utility;
using System.Threading;
using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace UnitTests.Utility
{
  public class HealthCheckTests
  {

    [Fact]
    public async void CheckHealthAsync_Returns_Result()
    {
      //arrange
      CancellationToken token = new CancellationToken();
      HealthCheck healthCheck = new HealthCheck();
      //act
      HealthCheckResult result = await healthCheck.CheckHealthAsync(null,token);
      //assert
      Assert.NotNull(result);
    }

  }
}

