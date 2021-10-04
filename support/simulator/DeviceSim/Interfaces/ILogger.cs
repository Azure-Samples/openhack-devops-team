using System;
using System.Collections.Generic;
using System.Text;

namespace DeviceSim.Interfaces
{
    public interface ILogger
    {
        void WriteMessage(LogLevel level, string message);
        void Report(Exception exception, LogCategory category);
    }
    
    public enum LogLevel
    {
        CRITICAL = 0,
        ERROR = 1,
        WARNING = 2,
        INFO = 3,
        VERBOSE = 4
    }

    public enum LogCategory
    {
        CONFIGERROR = 0,
        SQLERROR = 1 ,
        APIERROR =2
    }

}
