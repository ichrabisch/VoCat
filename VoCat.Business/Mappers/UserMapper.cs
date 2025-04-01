using Npgsql;
using System.Data;
using VoCat.Types;

namespace VoCat.Business.Mappers
{
    public static partial class Mapper
    {
        public static User ToUser(NpgsqlDataReader reader) {
            var user = new User
            {
                UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                UserName = reader.GetString(reader.GetOrdinal("user_name")),
                Email = reader.GetString(reader.GetOrdinal("email")),
                PasswordHash = reader.GetString(reader.GetOrdinal("password_hash")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("created_at")),
                LastLogin = reader.IsDBNull(reader.GetOrdinal("last_login")) 
                            ? null
                            : reader.GetDateTime("last_login"),
                PreferredLanguage = reader.GetString(reader.GetOrdinal("preferred_language"))
            };

            return user;
        }
    }
}
