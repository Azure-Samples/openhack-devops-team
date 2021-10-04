namespace Simulator.DataStore.Stores
{
    using Microsoft.Extensions.Configuration;
    using Newtonsoft.Json;
    using Simulator.DataObjects;
    using System;
    using System.Collections.Generic;
    using System.IO;
    using System.Net.Http;
    using System.Net.Http.Headers;
    using System.Threading.Tasks;
  
    public class UserStore : BaseStore//, IBaseStore<User>
    {
        private readonly IConfiguration Configuration;

        public UserStore(IHttpClientFactory clientFactory, string EndPoint, IConfiguration configuration) : base(clientFactory)
        {
            base.InitializeStore(EndPoint);
            Configuration = configuration;
        }

        public async Task<User> GetItemAsync(string id)
        {
            User user = null;
          //  var baseUrl = Configuration.GetValue<string>("USER_ROOT_URL");
            HttpResponseMessage response = await Client.GetAsync($"/api/user/{id}");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                user = await response.Content.ReadAsAsync<User>();
            }
            return user;
        }

        public async Task<List<User>> GetItemsAsync()
        {
            List<User> users = null;
            HttpResponseMessage response = await Client.GetAsync("/api/user/");

            if (response.IsSuccessStatusCode)
            {
                var contents = await response.Content.ReadAsStreamAsync();

                var serializer = new JsonSerializer();

                using (var sr = new StreamReader(contents))
                using (var jsonTextReader = new JsonTextReader(sr))
                {
                   users = serializer.Deserialize<List<User>>(jsonTextReader);
                }
            }
            return users;
        }
    }
}