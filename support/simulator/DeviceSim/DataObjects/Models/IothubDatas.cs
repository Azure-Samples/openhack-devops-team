using System;
using System.Collections.Generic;

namespace DeviceSim.DataObjects.Models
{
    public partial class IothubDatas
    {
        public string Id { get; set; }
        public byte[] Version { get; set; }
        public DateTimeOffset CreatedAt { get; set; }
        public DateTimeOffset? UpdatedAt { get; set; }
        public bool Deleted { get; set; }
    }
}
