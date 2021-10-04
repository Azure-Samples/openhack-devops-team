namespace DeviceSim.EF.SQL.DataObjects.Models
{
    using System;
    //using System.Data.Entity;
    //using System.Data.Entity.Infrastructure;

    using Microsoft.EntityFrameworkCore;
    using Microsoft.EntityFrameworkCore.Infrastructure;
    using Microsoft.EntityFrameworkCore.Metadata;
    
    public partial class mydrivingDBEntities : DbContext
    {
        private string connectionString = "Server=tcp:mydrivingdbserver-or76fh5yqpqg2.database.windows.net,1433;Initial Catalog=mydrivingDB;Persist Security Info=False;User ID=YourUserName;Password=OpenHack-85439610;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;";
        //public mydrivingDBEntities()
        //    : base("name=mydrivingDBEntities")
        //{
        //}

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseSqlServer(connectionString);
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            //throw new NotImplementedException("Change this Model");

        }

        //protected override void OnModelCreating(DbModelBuilder modelBuilder)
        //{
        //    throw new UnintentionalCodeFirstException();
        //}

        public virtual DbSet<Device> Devices { get; set; }
        public virtual DbSet<factMLOutputData> factMLOutputDatas { get; set; }
        public virtual DbSet<IOTHubData> IOTHubDatas { get; set; }
        public virtual DbSet<POIs> POIs { get; set; }
        public virtual DbSet<TripPoint> TripPoints { get; set; }
        public virtual DbSet<Trips> Trips { get; set; }
        public virtual DbSet<UserProfile> UserProfiles { get; set; }
    }
}
