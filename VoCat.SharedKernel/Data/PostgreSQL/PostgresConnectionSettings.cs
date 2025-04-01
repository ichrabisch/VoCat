namespace VoCat.SharedKernel.Data.PostgreSQL;
public class PostgresConnectionSettings
{
    public string Host { get; set; } = "localhost";
    public int Port { get; set; } = 5432;
    public string Database { get; set;} ="vocat";
    public string Username { get; set;} = "root";
    public string Password {get; set;} = "test";
    
    public string GetConnectionString(){
        return $"Host={Host};Port={Port};Database={Database};Username={Username};Password={Password}";
    }
}