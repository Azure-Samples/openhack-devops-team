using System.Diagnostics.CodeAnalysis;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Rewrite;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;
using poi.Data;

namespace poi
{
    [ExcludeFromCodeCoverage]
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

            services.AddHealthChecks()
                    .AddDbContextCheck<POIContext>()
                    .AddCheck<Utility.HealthCheck>("poi_health_check");

            var connectionString = poi.Utility.POIConfiguration.GetConnectionString(this.Configuration);
            services.AddDbContext<POIContext>(options =>
                options.UseSqlServer(connectionString));

            // Register the Swagger generator, defining 1 or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("docs", new OpenApiInfo {
                  Title = "Points Of Interest(POI) API",
                  Version = "v1",
                  Description = "API for the POI in the My Driving example app. https://github.com/Azure-Samples/openhack-devops"
                });
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, POIContext dbcontext)
        {
            if (env.IsDevelopment())
                app.UseDeveloperExceptionPage();

            app.UseRouting();

            app.UseRewriter(new RewriteOptions().AddRedirect("(.*)api/docs/poi$", "$1api/docs/poi/index.html"));

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger(c =>
                c.RouteTemplate = "swagger/{documentName}/poi/swagger.json"
            );

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.),
            // specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/docs/poi/swagger.json", "Points Of Interest(POI) API V1");
                c.DocumentTitle = "POI Swagger UI";
                c.RoutePrefix = "api/docs/poi";
            });

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapHealthChecks("api/healthcheck/poi", new HealthCheckOptions()
                {
                    AllowCachingResponses = false
                });
            });
        }
    }
}
