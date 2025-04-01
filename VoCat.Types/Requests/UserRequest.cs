namespace VoCat.Types.Requests
{
    public class UserRequest
    {
        public User UserContract { get; private set; }
        public UserRequest(User userContract)
        {
            UserContract = userContract;
        }
    }
}
