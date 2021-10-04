using System.Collections.Generic;
using System.Threading.Tasks;

namespace Simulator.DataStore.Abstractions
{
    public interface IBaseStore<T>
    {
        Task InitializeStoreAsync();

        Task<T> GetItemAsync(string id);

        Task<IEnumerable<T>> GetItemsAsync();

        Task<bool> CreateItemAsync(T item);

        Task<bool> UpdateItemAsync(T item);

        Task<bool> DeleteItemAsync(T item);
    }
}