using Npgsql;
using VoCat.Types;

namespace VoCat.Business.Mappers
{
    public static partial class Mapper
    {
        public static Word ToWord(NpgsqlDataReader reader)
        {
            var word = new Word
            {
                WordId = reader.GetGuid(reader.GetOrdinal("word_id")),
                WordText = reader.GetString(reader.GetOrdinal("word_text")),
                Translation = reader.GetString(reader.GetOrdinal("translation")),
                Definition = reader.IsDBNull(reader.GetOrdinal("definition"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("definition")),
                ExampleSentence = reader.IsDBNull(reader.GetOrdinal("example_sentence"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("example_sentence")),
                ImageUrl = reader.IsDBNull(reader.GetOrdinal("image_url"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("image_url")),
                AudioFileUrl = reader.IsDBNull(reader.GetOrdinal("audio_file_url"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("audio_file_url")),
                FolderId = reader.GetGuid(reader.GetOrdinal("folder_id")),
                UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                CreatedAt = reader.GetDateTime(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.IsDBNull(reader.GetOrdinal("updated_at"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("updated_at")),
                MasteryLevel = reader.IsDBNull(reader.GetOrdinal("mastery_level"))
                    ? 1
                    : reader.GetInt32(reader.GetOrdinal("mastery_level")),
                LastReviewed = reader.IsDBNull(reader.GetOrdinal("last_reviewed"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("last_reviewed")),
                IsFromRecognition = reader.IsDBNull(reader.GetOrdinal("is_from_recognition"))
                    ? false
                    : reader.GetBoolean(reader.GetOrdinal("is_from_recognition"))
            };
            return word;
        }
    }
}