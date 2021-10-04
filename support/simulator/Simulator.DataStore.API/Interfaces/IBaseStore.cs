using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Simulator.DataStore.Abstractions
{
    public interface IBaseStore<T>
    {
        Task InitializeStore(string EndPoint);
        Task<T> GetItemAsync(string id);
        Task<List<T>> GetItemsAsync();
        Task<T> CreateItemAsync(T item);
        Task<bool> UpdateItemAsync(T item);
        Task<bool> DeleteItemAsync(T item);
    }
}
