using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using VoCat.Orchestration;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly UserOrchestration _userOrchestration;
        public UserController(UserOrchestration userOrchestration)
        {
            _userOrchestration = userOrchestration;
        }

        [HttpPost("signup")]
        public bool SignUp(UserRequest request)
        {
            return _userOrchestration.CreateUser(request).Data;
        }

        [HttpPost("login")]
        public User LogIn(UserRequest request)
        {
            return _userOrchestration.Login(request).Data;
        }
    }
}
