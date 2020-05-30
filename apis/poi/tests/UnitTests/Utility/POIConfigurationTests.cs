using Xunit;
using poi.Utility;
using System.Threading;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using Microsoft.Extensions.Primitives;
using System;

namespace UnitTests.Utility
{
  public class POIConfigurationTests
  {

    [Fact]
    public async void Foo()
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
  public class MockConfiguration : IConfiguration
{
    public IConfigurationSection GetSection(string key)
    {
        return new MockConfigurationSection()
        {
            Value = "123"
        };
    }

    public IEnumerable<IConfigurationSection> GetChildren()
    {
        var configurationSections = new List<IConfigurationSection>()
        {
            new MockConfigurationSection()
            {
                Value = "MyConfigStr"
            }
        };
        return configurationSections;
    }

    public Microsoft.Extensions.Primitives.IChangeToken GetReloadToken()
    {
        throw new System.NotImplementedException();
    }

    public string this[string key]
    {
        get => throw new System.NotImplementedException();
        set => throw new System.NotImplementedException();
    }
}
public class MockConfigurationSection : IConfigurationSection
{
    public IConfigurationSection GetSection(string key)
    {
        return this;
    }

    public IEnumerable<IConfigurationSection> GetChildren()
    {
        return new List<IConfigurationSection>();
    }

    public IChangeToken GetReloadToken()
    {
        return new MockChangeToken();
    }

    public string this[string key]
    {
        get => throw new System.NotImplementedException();
        set => throw new System.NotImplementedException();
    }

    public string Key { get; }
    public string Path { get; }
    public string Value { get; set; }
}

public class MockChangeToken : IChangeToken
{
    public IDisposable RegisterChangeCallback(Action<object> callback, object state)
    {
        return new MockDisposable();
    }

    public bool HasChanged { get; }
    public bool ActiveChangeCallbacks { get; }
}

public class MockDisposable : IDisposable
{
    public void Dispose()
    {
    }
}

}

