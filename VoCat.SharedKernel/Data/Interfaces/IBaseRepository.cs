using Npgsql;

namespace VoCat.SharedKernel.Data.Interfaces;

public interface IBaseRepository<T> : IDisposable where T : class
{
    public T? ExecuteReaderSingle(string storedProcedure, Func<NpgsqlDataReader, T> mapper, Dictionary<string, object> parameters);
    public int ExecuteNonQuery(string storedProcedure, Dictionary<string, object> parameters);
    public NpgsqlCommand CreateCommand(string storedProcedure, Dictionary<string, object> parameters);

}