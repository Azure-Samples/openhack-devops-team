using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Newtonsoft.Json;
using poi.Data;

namespace IntegrationTests
{
    public class Startup
    {
        public Startup(IConfiguration configuration) 
            => Configuration = configuration;

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers()
                .AddNewtonsoftJson((options =>
                {
                    options.SerializerSettings.Formatting = Formatting.Indented;
                }));

            // Add a database context (ApplicationDbContext) using an in-memory
            // database for testing.
            services
                .AddEntityFrameworkInMemoryDatabase()
                .AddDbContext<POIContext>((serviceProvider, options) =>
                {
                    options.UseInMemoryDatabase("InMemoryDbForTesting");
                    options.UseInternalServiceProvider(serviceProvider);
                });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
                app.UseDeveloperExceptionPage();
        }
    }
}
