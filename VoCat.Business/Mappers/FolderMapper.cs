using Npgsql;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.Business.Mappers
{
    public static partial class Mapper
    {
        public static Folder ToFolder(NpgsqlDataReader reader) 
        {
            var folder = new Folder
            {
                FolderId = reader.GetGuid(reader.GetOrdinal("folder_id")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                ParentFolderId = reader.IsDBNull(reader.GetOrdinal("parent_folder_id")) 
                    ? null
                    : reader.GetGuid(reader.GetOrdinal("parent_folder_id")),
                UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.IsDBNull(reader.GetOrdinal("updated_at")) 
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("updated_at"))
            };
            return folder;
        }

    }
}
