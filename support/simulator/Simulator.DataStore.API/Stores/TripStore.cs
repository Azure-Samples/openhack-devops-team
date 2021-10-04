namespace Simulator.DataStore.Stores
{
    using Simulator.DataObjects;
    using Simulator.DataStore.Abstractions;
    using System.Collections.Generic;
    using System.Net.Http;
    using System.Threading.Tasks;

    public class TripStore : BaseStore, IBaseStore<Trip>
    {
        public TripStore(string EndPoint)
        {
            base.InitializeStore(EndPoint);
        }

        public async Task<Trip> GetItemAsync(string id)
        {
            Trip trip = null;
            HttpResponseMessage response = await Client.GetAsync($"/api/trips/{id}");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                trip = await response.Content.ReadAsAsync<Trip>();
            }
            return trip;
        }

        public async Task<List<Trip>> GetItemsAsync()
        {
            List<Trip> trips = null;
            HttpResponseMessage response = await Client.GetAsync("api/trips/");
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                trips = await response.Content.ReadAsAsync<List<Trip>>();
            }
            return trips;
        }

        public async Task<Trip> CreateItemAsync(Trip item)
        {
            HttpResponseMessage response = await Client.PostAsJsonAsync<Trip>("api/trips", item);
            response.EnsureSuccessStatusCode();
            if (response.IsSuccessStatusCode)
            {
                response.Content.Headers.ContentType.MediaType = "application/json";
                item = await response.Content.ReadAsAsync<Trip>();
            }
            return item;
        }

        public async Task<bool> UpdateItemAsync(Trip item)
        {
            HttpResponseMessage response = await Client.PatchAsJsonAsync($"api/trips/{item.Id}", item);
            response.EnsureSuccessStatusCode();
            if (response.IsSuccessStatusCode)
                response.Content.Headers.ContentType.MediaType = "application/json";
            return true;
        }

        public async Task<bool> DeleteItemAsync(Trip item)
        {
            HttpResponseMessage response = await Client.DeleteAsync($"api/trips/{item.Id}");
            response.EnsureSuccessStatusCode();
            if (response.IsSuccessStatusCode)
                response.Content.Headers.ContentType.MediaType = "application/json";
            return true;
        }
    }
}