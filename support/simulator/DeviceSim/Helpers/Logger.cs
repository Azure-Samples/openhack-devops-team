using System;
using System.Collections.Generic;
using System.Text;
using DeviceSim.Interfaces;

namespace DeviceSim.Helpers
{
    public class Logger : ILogger
    {
        public void Report(Exception exception, LogCategory category)
        {
            throw new NotImplementedException();
        }

        public void WriteMessage( LogLevel level, string message)
        {
            throw new NotImplementedException();
        }
    }
}
