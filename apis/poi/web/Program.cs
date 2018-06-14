using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using poi.Utility;
namespace poi
{
    public class Program
    {
        public static void Main(string[] args)
        {

            BuildWebHost(args).Run();

        }

        public static IWebHost BuildWebHost(string[] args) {

            return CreateWebHostBuilder(args).Build();
        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) {
            //used to read env variables for host/port
            var configuration = new ConfigurationBuilder()
            .AddEnvironmentVariables()
            .Build();

            var host = new WebHostBuilder()
                .UseKestrel()
                .UseContentRoot(Directory.GetCurrentDirectory())
                .UseConfiguration(configuration)
                .UseIISIntegration()
                .ConfigureLogging((hostingContext, logging) =>
                {
                    logging.AddConfiguration(hostingContext.Configuration.GetSection("Logging"));
                    logging.AddConsole();
                    logging.AddDebug();
                })
                .ConfigureAppConfiguration((hostingContext, config) =>
                {
                    var env = hostingContext.HostingEnvironment;
                    config.SetBasePath(Directory.GetCurrentDirectory());
                    config.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
                    config.AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true, reloadOnChange: true);
                    config.AddEnvironmentVariables();
                    config.AddCommandLine(args);
                })
                .UseStartup<Startup>()
                .UseUrls(POIConfiguration.GetUri(configuration));

            return host;

        }
    }
}
