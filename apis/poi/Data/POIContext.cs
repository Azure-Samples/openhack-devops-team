using Microsoft.EntityFrameworkCore;
using poi.Models;

namespace poi.Data
{
    public class POIContext : DbContext
    {
        public POIContext(DbContextOptions<POIContext> options) : base(options)
        {

        }

        public DbSet<POI> POIs { get; set; }
    }
}