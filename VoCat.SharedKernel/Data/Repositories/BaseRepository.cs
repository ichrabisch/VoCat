using System.Data;
using System.Net;
using Npgsql;
using VoCat.SharedKernel.Data.Interfaces;
using VoCat.SharedKernel.Data.PostgreSQL;

namespace VoCat.SharedKernel.Data.Repositories;
public abstract class BaseRepository<T> : IBaseRepository<T> where T : class
{
    private readonly PostgresConnectionManager _connectionManager;
    public BaseRepository(PostgresConnectionManager connectionManager){
        _connectionManager = connectionManager;
    }
    public NpgsqlCommand CreateFunctionCommand(string functionName, Dictionary<string, object> parameters)
    {
        var connection = _connectionManager.CreateConnection();

        var parameterList = parameters?.Select(p =>
        {
            var pgParamName = p.Key.StartsWith("@") ? p.Key.Substring(1) : p.Key;
            return $"{pgParamName} := {p.Key}";
        }).ToList() ?? new List<string>();

        var sql = $"SELECT * FROM {functionName}({string.Join(", ", parameterList)})";
        var command = new NpgsqlCommand(sql, connection);

        if(parameters != null)
        {
            foreach( var param in parameters )
            {
                command.Parameters.AddWithValue(param.Key, param.Value);
            }
        }
        return command;
    }
    public NpgsqlCommand CreateCommand(string storedProcedure, Dictionary<string, object> parameters)
    {
        var connection = _connectionManager.CreateConnection();
        var command = new NpgsqlCommand(storedProcedure, connection)
        {
            CommandType = CommandType.StoredProcedure
        };

        if (parameters != null)
        {
            foreach (var parameter in parameters)
            {
                var parameterName = parameter.Key.StartsWith("@") ? parameter.Key.Substring(1) : parameter.Key;
                command.Parameters.AddWithValue(parameterName, parameter.Value ?? DBNull.Value);
            }
        }

        return command;
    }

    public int ExecuteNonQuery(string storedProcedure, Dictionary<string, object> parameters)
    {
        try
        {
            using (var command = CreateCommand(storedProcedure, parameters))
            {
                var result = command.ExecuteNonQuery();
                return result;
            }
        }
        finally
        {
            _connectionManager.CloseConnection();
        }
    }
    public void Dispose()
    {
        _connectionManager.CloseConnection();
    }
    public T? ExecuteReaderSingle(string functionName, Func<NpgsqlDataReader, T> mapper, Dictionary<string, object> parameters)
    {
        try{
            using(var command = CreateFunctionCommand(functionName, parameters))
            using(var reader = command.ExecuteReader()){
                return reader.Read() ? mapper(reader) : default;
            }
        }
        finally{
            _connectionManager.CloseConnection();
        }
    }

    public List<T>? ExecuteReader(string functionName, Func<NpgsqlDataReader, T> mapper, Dictionary<string, object> parameters)
    {
        try {
            using(var command = CreateFunctionCommand(functionName, parameters))
            using(var reader = command.ExecuteReader())
            {
                List<T> objects = new List<T>();
                while (reader.Read()) { 
                    objects.Add(mapper(reader));
                }
                return objects;
            }
        }
        finally
        {
            _connectionManager.CloseConnection();
        }
    }
    protected virtual GenericResult<TResult> ExecuteSafely<TResult>(Func<TResult> databaseOperation)
    {
        try
        {
            var result = databaseOperation();
            return GenericResult<TResult>.Success(result);
        }
        catch (PostgresException ex)
        {
            var problemDetails = new ProblemDetails
            {
                Status = (int)HttpStatusCode.InternalServerError,
                Title = GlobalConsts.InternalServerErrorTitle,
                Detail = ex.Message
            };
            return GenericResult<TResult>.Exception(problemDetails);
        }
        finally
        {
            _connectionManager.CloseConnection();
        }
    }
}