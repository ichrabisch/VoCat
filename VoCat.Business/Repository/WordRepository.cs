using VoCat.SharedKernel.Data.PostgreSQL;
using VoCat.SharedKernel.Data.Repositories;
using VoCat.SharedKernel;
using VoCat.Types.Requests;
using VoCat.Types;
using VoCat.Business.Mappers;

public class WordRepository : BaseRepository<Word>
{
    public WordRepository(PostgresConnectionManager connectionManager) : base(connectionManager)
    {
    }

    public GenericResult<bool> CreateWord(WordRequest request)
    {
        return ExecuteSafely(() =>
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>
            {
                {"@p_word_id", request.WordContract.WordId},
                {"@p_word_text", request.WordContract.WordText},
                {"@p_translation", request.WordContract.Translation},
                {"@p_folder_id", request.WordContract.FolderId},
                {"@p_user_id", request.WordContract.UserId},
                {"@p_mastery_level", (int)GlobalConsts.MasteryLevel.NeedsDailyPractice}
            };
            var queryResult = ExecuteNonQuery("sp_CreateWord", parameters);
            return true;
            //TODO: CHECK IF RETURN TRUE OR NOT
            //queryResult != GlobalConsts.CreateError;
        });
    }

    public GenericResult<List<Word>?> SelectWordsByFolderId(WordRequest request)
    {
        return ExecuteSafely(() =>
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>
            {
                {"@p_folder_id", request.WordContract.FolderId}
            };
            return ExecuteReader("fn_SelectWordsByFolderId", Mapper.ToWord, parameters);
        });
    }

    public GenericResult<Word?> SelectWordById(WordRequest request)
    {
        return ExecuteSafely(() =>
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>
            {
                {"@p_word_id", request.WordContract.WordId}
            };
            return ExecuteReaderSingle("fn_SelectWordById", Mapper.ToWord, parameters);
        });
    }

    public GenericResult<bool> UpdateWord(WordRequest request)
    {
        return ExecuteSafely(() =>
        {
            Dictionary<string, object> parameters = Mapper.ToParameters(request);
            ExecuteNonQuery("sp_UpdateWord", parameters);
            return true;
        });
    }
}