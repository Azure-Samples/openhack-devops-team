using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Swashbuckle.AspNetCore.Swagger;
using System.Reflection;
using poi.Data;
using poi.Utility;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Rewrite;

namespace poi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddMvc()
                .AddJsonOptions(options =>
                {
                    options.SerializerSettings.Formatting = Formatting.Indented;
                });

            var connectionString = poi.Utility.POIConfiguration.GetConnectionString(this.Configuration);
            services.AddDbContext<POIContext>(options =>
                options.UseSqlServer(connectionString));

            // Register the Swagger generator, defining 1 or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("docs", new Info { Title = "Points Of Interest(POI) API", Version = "v1" });
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseBrowserLink();
            }

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

            app.UseMvc();
        }
    }
}
