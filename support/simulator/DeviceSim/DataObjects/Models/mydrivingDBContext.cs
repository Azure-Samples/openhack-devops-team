using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;

namespace DeviceSim.DataObjects.Models
{
    public partial class mydrivingDBContext : DbContext
    {
        public virtual DbSet<Devices> Devices { get; set; }
        public virtual DbSet<IothubDatas> IothubDatas { get; set; }
        public virtual DbSet<Pois> Pois { get; set; }
        public virtual DbSet<TripPoints> TripPoints { get; set; }
        public virtual DbSet<Trips> Trips { get; set; }
        public virtual DbSet<UserProfiles> UserProfiles { get; set; }
        public virtual DbSet<Poisource> Poisource { get; set; }
        public virtual DbSet<TripPointSource> TripPointSource { get; set; }
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer(connString);
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Devices>(entity =>
            {
                entity.HasIndex(e => e.CreatedAt)
                    .HasName("IX_CreatedAt")
                    .ForSqlServerIsClustered();

                entity.HasIndex(e => e.UserProfileId)
                    .HasName("IX_UserProfile_Id");

                entity.Property(e => e.Id)
                    .HasMaxLength(128)
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

                entity.Property(e => e.UserProfileId)
                    .HasColumnName("UserProfile_Id")
                    .HasMaxLength(128);

                entity.Property(e => e.Version)
                    .IsRequired()
                    .IsRowVersion();

                entity.HasOne(d => d.UserProfile)
                    .WithMany(p => p.Devices)
                    .HasForeignKey(d => d.UserProfileId)
                    .HasConstraintName("FK_dbo.Devices_dbo.UserProfiles_UserProfile_Id");
            });

            
            modelBuilder.Entity<IothubDatas>(entity =>
            {
                entity.ToTable("IOTHubDatas");

                entity.HasIndex(e => e.CreatedAt)
                    .HasName("IX_CreatedAt")
                    .ForSqlServerIsClustered();

                entity.Property(e => e.Id)
                    .HasMaxLength(128)
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

                entity.Property(e => e.Version)
                    .IsRequired()
                    .IsRowVersion();
            });

            modelBuilder.Entity<Pois>(entity =>
            {
                entity.ToTable("POIs");

                entity.Property(e => e.Id)
                    .HasMaxLength(128)
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

                entity.Property(e => e.Poitype).HasColumnName("POIType");

                entity.Property(e => e.RecordedTimeStamp).HasMaxLength(50);

                entity.Property(e => e.Timestamp)
                    .HasColumnType("datetime")
                    .HasDefaultValueSql("('1900-01-01T00:00:00.000')");

                entity.Property(e => e.Version)
                    .IsRequired()
                    .IsRowVersion();
            });

            modelBuilder.Entity<Poisource>(entity =>
            {
                entity.ToTable("POISource");

                entity.Property(e => e.Id)
                    .HasMaxLength(128)
                    .ValueGeneratedNever();

                entity.Property(e => e.Poitype).HasColumnName("POIType");

                entity.Property(e => e.RecordedTimeStamp).HasMaxLength(50);
            });

            modelBuilder.Entity<TripPoints>(entity =>
            {
                entity.HasIndex(e => e.CreatedAt)
                    .HasName("IX_CreatedAt")
                    .ForSqlServerIsClustered();

                entity.HasIndex(e => e.TripId)
                    .HasName("IX_TripId");

                entity.Property(e => e.Id)
                    .HasMaxLength(128)
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

                entity.Property(e => e.HasObddata).HasColumnName("HasOBDData");

                entity.Property(e => e.HasSimulatedObddata).HasColumnName("HasSimulatedOBDData");

                entity.Property(e => e.RecordedTimeStamp).HasColumnType("datetime");

                entity.Property(e => e.Rpm).HasColumnName("RPM");

                entity.Property(e => e.TripId).HasMaxLength(128);

                entity.Property(e => e.Version)
                    .IsRequired()
                    .IsRowVersion();

                entity.Property(e => e.Vin).HasColumnName("VIN");

                entity.HasOne(d => d.Trip)
                    .WithMany(p => p.TripPoints)
                    .HasForeignKey(d => d.TripId)
                    .HasConstraintName("FK_dbo.TripPoints_dbo.Trips_TripId");
            });

            modelBuilder.Entity<TripPointSource>(entity =>
            {
                entity.HasKey(e => e.Trippointid);

                entity.Property(e => e.Trippointid)
                    .HasColumnName("trippointid")
                    .HasMaxLength(36)
                    .IsUnicode(false)
                    .ValueGeneratedNever();

                entity.Property(e => e.Distancewithmil).HasColumnName("distancewithmil");

                entity.Property(e => e.Enginefuelrate).HasColumnName("enginefuelrate");

                entity.Property(e => e.Engineload).HasColumnName("engineload");

                entity.Property(e => e.Enginerpm).HasColumnName("enginerpm");

                entity.Property(e => e.Field21).HasColumnName("FIELD21");

                entity.Property(e => e.Lat)
                    .HasColumnName("lat")
                    .HasColumnType("numeric(18, 15)");

                entity.Property(e => e.Lon)
                    .HasColumnName("lon")
                    .HasColumnType("numeric(19, 14)");

                entity.Property(e => e.Longtermfuelbank).HasColumnName("longtermfuelbank");

                entity.Property(e => e.Mafflowrate).HasColumnName("mafflowrate");

                entity.Property(e => e.Name)
                    .HasColumnName("name")
                    .HasMaxLength(30)
                    .IsUnicode(false);

                entity.Property(e => e.Outsidetemperature)
                    .HasColumnName("outsidetemperature")
                    .HasMaxLength(30)
                    .IsUnicode(false);

                entity.Property(e => e.Recordedtimestamp)
                    .IsRequired()
                    .HasColumnName("recordedtimestamp")
                    .HasMaxLength(28)
                    .IsUnicode(false);

                entity.Property(e => e.Relativethrottleposition).HasColumnName("relativethrottleposition");

                entity.Property(e => e.Runtime).HasColumnName("runtime");

                entity.Property(e => e.Sequence).HasColumnName("sequence");

                entity.Property(e => e.Shorttermfuelbank).HasColumnName("shorttermfuelbank");

                entity.Property(e => e.Speed).HasColumnName("speed");

                entity.Property(e => e.Throttleposition).HasColumnName("throttleposition");

                entity.Property(e => e.Tripid)
                    .IsRequired()
                    .HasColumnName("tripid")
                    .HasMaxLength(36)
                    .IsUnicode(false);

                entity.Property(e => e.Userid)
                    .IsRequired()
                    .HasColumnName("userid")
                    .HasMaxLength(33)
                    .IsUnicode(false);
            });

            modelBuilder.Entity<Trips>(entity =>
            {
                entity.HasIndex(e => e.CreatedAt)
                    .HasName("IX_CreatedAt")
                    .ForSqlServerIsClustered();

                entity.Property(e => e.Id)
                    .HasMaxLength(128)
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

                entity.Property(e => e.EndTimeStamp).HasColumnType("datetime");

                entity.Property(e => e.HasSimulatedObddata).HasColumnName("HasSimulatedOBDData");

                entity.Property(e => e.RecordedTimeStamp).HasColumnType("datetime");

                entity.Property(e => e.Version)
                    .IsRequired()
                    .IsRowVersion();
            });

            modelBuilder.Entity<UserProfiles>(entity =>
            {
                entity.HasIndex(e => e.CreatedAt)
                    .HasName("IX_CreatedAt")
                    .ForSqlServerIsClustered();

                entity.Property(e => e.Id)
                    .HasMaxLength(128)
                    .HasDefaultValueSql("(newid())");

                entity.Property(e => e.CreatedAt).HasDefaultValueSql("(sysutcdatetime())");

                entity.Property(e => e.Version)
                    .IsRequired()
                    .IsRowVersion();
            });
        }
    }
}
