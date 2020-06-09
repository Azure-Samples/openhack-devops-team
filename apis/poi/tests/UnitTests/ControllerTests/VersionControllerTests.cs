using Xunit;
using poi.Controllers;
using System;

namespace UnitTests.ControllerTests
{
    public class VersionControllerTests
    {

        [Fact]
        public void Returns_Default_If_EnvironmentVariable_NotSet()
        {
            //arrange
            //explicitly set this to null as to clear any previous state
            Environment.SetEnvironmentVariable("APP_VERSION",null);             
            var controller = new VersionController();
            var defaultValue = "default";

            //act
            var result = controller.GetVersion();

            //assert
            Assert.NotNull(result);
            Assert.Equal(defaultValue,result);
        }

        [Fact]
        public void Returns_AppVersion_FromEnvironmentVariable()
        {
            //arrange
            var version = "fake_test_version";
            Environment.SetEnvironmentVariable("APP_VERSION",version);
            var controller = new VersionController();

            //act
            var result = controller.GetVersion();
            
            //assert
            Assert.NotNull(result);
            Assert.Equal(version,result);
        }        

 
        
    }
}
