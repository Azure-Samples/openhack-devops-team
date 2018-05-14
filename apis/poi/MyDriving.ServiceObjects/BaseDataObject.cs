using System;
using System.Collections.Generic;
using System.Text;

namespace MyDriving.ServiceObjects
{
    public class BaseDataObject
    {
        public string Id { get; set; }

        public BaseDataObject()
        {
            Id = Guid.NewGuid().ToString();
        }
    }
}
