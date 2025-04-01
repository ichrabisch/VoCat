using Npgsql;
using System.Net;
using VoCat.Business.Mappers;
using VoCat.SharedKernel;
using VoCat.SharedKernel.Data.PostgreSQL;
using VoCat.SharedKernel.Data.Repositories;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.Business.Repository
{
    public class FolderRepository : BaseRepository<Folder>
    {
        #region Constructor
        public FolderRepository(PostgresConnectionManager connectionManager) : base(connectionManager)
        {
        }
        #endregion

        #region Method
        public GenericResult<bool> CreateFolder(FolderRequest request)
        {
            return ExecuteSafely(() =>
            {
                Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    {"@p_folder_id", request.FolderContract.FolderId },
                    {"@p_folder_name", request.FolderContract.Name},
                    {"@p_user_id", request.FolderContract.UserId}
                };
                var queryResult = ExecuteNonQuery("sp_CreateFolder", parameters);
                return true;
                //TODO: CHECK IF RETURN TRUE OR NOT
                //queryResult != GlobalConsts.CreateError;
            });
        }

        public GenericResult<List<Folder>?> SelectAllFolders(FolderRequest request)
        {
            return ExecuteSafely(() =>
            {
                Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    {"@p_user_id", request.FolderContract.UserId}
                };
                return ExecuteReader("fn_SelectAllFolders", Mapper.ToFolder, parameters);
            });
        }

        public GenericResult<bool> UpdateFolder(FolderRequest request)
        {
            return ExecuteSafely(() =>
            {
                Dictionary<string, object> parameters = Mapper.ToParameters(request);
                ExecuteNonQuery("sp_UpdateFolder", parameters);
                return true;
            });
        }
        #endregion
    }
}