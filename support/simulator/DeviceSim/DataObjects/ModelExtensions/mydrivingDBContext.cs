using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using DeviceSim.Helpers;

namespace DeviceSim.DataObjects.Models
{
    public partial class mydrivingDBContext : DbContext
    {
        private string _connectionString;

        public string connString
        {
            get { return _connectionString; }
            set { _connectionString = value; }
        }

        public mydrivingDBContext(DBConnectionInfo dBConnectionInfo) : base()
        {
            ConnectionStringHelper csHelper = new ConnectionStringHelper(dBConnectionInfo);
            connString = csHelper.ConnectionString;
        }
    }
}
