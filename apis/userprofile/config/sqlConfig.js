const sqlConfig = {
    userName: process.env.SQL_USER || '',
    password: process.env.SQL_PASSWORD || '',
    server: process.env.SQL_SERVER || '', // You can use 'localhost\\instance' to connect to named instance
    options: {
        encrypt: true, // Use this if you're on Windows Azure
        database: process.env.SQL_DBNAME || 'mydrivingdb',
        MultipleActiveResultSets: false,
        TrustServerCertificate: false,
        rowCollectionOnDone: true
        // Persist Security Info=False;Connection Timeout=30
    }
};

exports = module.exports = sqlConfig;
