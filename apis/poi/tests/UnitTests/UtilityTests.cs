using Xunit;
using poi.Utility;

namespace UnitTests
{
    public class UtilityTests
    {
        [Fact]
        public void TestLoggingEvents()
        {
            Assert.Equal(1000, LoggingEvents.Healthcheck);
            Assert.Equal(2001, LoggingEvents.GetAllPOIs);
        }
    }
}
