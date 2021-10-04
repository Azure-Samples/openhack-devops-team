using System;
using System.Collections.Generic;
using System.Text;

namespace DeviceSim.Helpers
{
    public class ConnectionStringHelper
    {
        private string connectionString;
        public string ConnectionString
        {
            get => connectionString;
            private set => connectionString = value;
        }

        private void ConnectionStringBuilder(DBConnectionInfo dBConnectionInfo)
        {
             ConnectionString = $"Server=tcp:{dBConnectionInfo.DBServer},1433;Initial Catalog={dBConnectionInfo.DBCatalog};Persist Security Info=False;User ID={dBConnectionInfo.DBUserName};Password={dBConnectionInfo.DBPassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60";

        }
        public ConnectionStringHelper(DBConnectionInfo dBConnectionInfo)
        {
            ConnectionStringBuilder(dBConnectionInfo);
        }

    }

    public struct DBConnectionInfo
    {
        public string DBServer;
        public string DBCatalog;
        public string DBUserName;
        public string DBPassword;
    }
}
