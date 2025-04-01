using System.Data;
using Npgsql;

namespace VoCat.SharedKernel.Data.PostgreSQL;

public class PostgresConnectionManager
{
    private readonly PostgresConnectionSettings _settings;
    private NpgsqlConnection? _connection;
    public PostgresConnectionManager(PostgresConnectionSettings settings)
    {
        _settings = settings;
    }

    public NpgsqlConnection CreateConnection()
    {
        if(_connection == null){
            _connection = new NpgsqlConnection(_settings.GetConnectionString());
        }
        if(_connection.State != ConnectionState.Open){
            _connection.Open();
        }
        return _connection;
    }
    public void CloseConnection(){
        if(_connection != null && _connection.State == ConnectionState.Open){
            _connection.Close();
        }
    }
}