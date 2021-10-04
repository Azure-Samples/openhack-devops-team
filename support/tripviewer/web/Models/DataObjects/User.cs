namespace Simulator.DataObjects
{
    using Newtonsoft.Json;
    using System;

    public partial class User
    {
        [JsonProperty("id")]
        public Guid Id { get; set; }

        [JsonProperty("firstName")]
        public string FirstName { get; set; }

        [JsonProperty("lastName")]
        [JsonConverter(typeof(ParseStringConverter))]
        public long LastName { get; set; }

        [JsonProperty("userId")]
        public string UserId { get; set; }

        [JsonProperty("profilePictureUri")]
        public string ProfilePictureUri { get; set; }

        [JsonProperty("rating")]
        public long Rating { get; set; }

        [JsonProperty("ranking")]
        public long Ranking { get; set; }

        [JsonProperty("totalDistance")]
        public double TotalDistance { get; set; }

        [JsonProperty("totalTrips")]
        public long TotalTrips { get; set; }

        [JsonProperty("totalTime")]
        public long TotalTime { get; set; }

        [JsonProperty("hardStops")]
        public long HardStops { get; set; }

        [JsonProperty("hardAccelerations")]
        public long HardAccelerations { get; set; }

        [JsonProperty("fuelConsumption")]
        public long FuelConsumption { get; set; }

        [JsonProperty("maxSpeed")]
        public long MaxSpeed { get; set; }

        [JsonProperty("version")]
        public string Version { get; set; }

        [JsonProperty("createdAt")]
        public DateTime CreatedAt { get; set; }

        [JsonProperty("updatedAt")]
        public DateTime UpdatedAt { get; set; }

        [JsonProperty("deleted")]
        public bool Deleted { get; set; }
    }

    public partial class User
    {
        public static User FromJson(string json) => JsonConvert.DeserializeObject<User>(json, Converter.Settings);
    }

    public static class UserSerializer
    {
        public static string ToJson(this User self) => JsonConvert.SerializeObject(self, Converter.Settings);
    }

    internal class ParseStringConverter : JsonConverter
    {
        public override bool CanConvert(Type t) => t == typeof(long) || t == typeof(long?);

        public override object ReadJson(JsonReader reader, Type t, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType == JsonToken.Null) return null;
            var value = serializer.Deserialize<string>(reader);
            long l;
            if (Int64.TryParse(value, out l))
            {
                return l;
            }
            throw new Exception("Cannot unmarshal type long");
        }

        public override void WriteJson(JsonWriter writer, object untypedValue, JsonSerializer serializer)
        {
            if (untypedValue == null)
            {
                serializer.Serialize(writer, null);
                return;
            }
            var value = (long)untypedValue;
            serializer.Serialize(writer, value.ToString());
            return;
        }

        public static readonly ParseStringConverter Singleton = new ParseStringConverter();
    }
}