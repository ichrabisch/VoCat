using VoCat.Business.Repository;
using VoCat.SharedKernel;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.Orchestration;
public class UserOrchestration
{
    #region Constructor
    private readonly UserRepository _userRepository;
    public UserOrchestration(UserRepository userRepository){
        _userRepository = userRepository;
    }
    #endregion

    #region Method
    public GenericResult<bool> CreateUser(UserRequest request){
        // TODO: Hash password
        var result = _userRepository.CreateUser(request);
        return result;
    }

    public GenericResult<User> Login(UserRequest request)
    {
        var result = _userRepository.SelectUserByEmail(request);
        if (result.Data != null && request.UserContract.PasswordHash == result.Data.PasswordHash) 
        {
            return result; 
        }
        return GenericResult<User>.Failure(GlobalConsts.WrongCredentials);
    }
    #endregion
}