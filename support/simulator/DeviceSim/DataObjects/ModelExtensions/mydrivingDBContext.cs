using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using DeviceSim.Helpers;

namespace DeviceSim.DataObjects.Models
{
    public partial class MydrivingDBContext : DbContext
    {
        private string _connectionString;

        public string ConnString
        {
            get { return _connectionString; }
            set { _connectionString = value; }
        }

        public MydrivingDBContext(DBConnectionInfo dBConnectionInfo) : base()
        {
            ConnectionStringHelper csHelper = new ConnectionStringHelper(dBConnectionInfo);
            ConnString = csHelper.ConnectionString;
        }
    }
}
