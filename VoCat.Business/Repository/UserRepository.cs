using System.Net;
using Npgsql;
using VoCat.SharedKernel;
using VoCat.SharedKernel.Data.PostgreSQL;
using VoCat.SharedKernel.Data.Repositories;
using VoCat.Types;
using VoCat.Types.Requests;
using VoCat.Business.Mappers;

namespace VoCat.Business.Repository
{
    public class UserRepository : BaseRepository<User>
    {
        #region Constructor
        public UserRepository(PostgresConnectionManager connectionManager) : base(connectionManager)
        {
        }
        #endregion

        #region Method
        public GenericResult<bool> CreateUser(UserRequest request)
        {
            return ExecuteSafely(() =>
            {
                Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "@p_user_id", request.UserContract.UserId },
                    { "@p_user_name", request.UserContract.UserName },
                    { "@p_email", request.UserContract.Email },
                    { "@p_password_hash", request.UserContract.PasswordHash }
                };
                var queryResult = ExecuteNonQuery("sp_CreateUser", parameters);
                return true;
                //TODO: CHECK IF RETURN TRUE OR NOT
                //queryResult != GlobalConsts.CreateError;
            });
        }

        public GenericResult<User?> SelectUserByEmail(UserRequest request)
        {
            return ExecuteSafely(() =>
            {
                Dictionary<string, object> parameters = new Dictionary<string, object>
                {
                    { "@p_email", request.UserContract.Email }
                };

                return ExecuteReaderSingle("fn_selectuserbyemail", Mapper.ToUser, parameters);
            });
        }
        #endregion
    }
}