using VoCat.SharedKernel;

namespace VoCat.Types;

public class User
{
    public User()
    {
        userId = Guid.NewGuid();
        createdAt = DateTime.UtcNow;
        folders = new List<Folder>();
    }

    #region UserId
    private Guid userId;
    public Guid UserId
    {
        get => userId;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(UserId));
            userId = value;
        }
    }
    #endregion
    #region UserName
    private string userName;
    public string UserName{
        get => userName;
        set
        {
           GuardClause.EnsureNotNullOrEmpty(value,nameof(UserName)); 
           userName = value;
        }
    }
    #endregion
    #region Email
    private string email;
    public string Email{
        get =>email;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value,nameof(Email));
            email = value;
        }
    }
    #endregion
    #region PasswordHash
    private string passwordHash;
    public string PasswordHash{
        get => passwordHash;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(PasswordHash));
            passwordHash = value;
        }
    }
    #endregion
    #region CreatedAt
    private DateTime createdAt;
    public DateTime CreatedAt{
        get => createdAt;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value,nameof(CreatedAt));
            createdAt = value;
        }
    }
    #endregion
    #region LastLogin
    private DateTime? lastLogin;
    public DateTime? LastLogin{
        get => lastLogin;
        set
        {
            lastLogin = value;
        }
    }
    #endregion
    #region PreferredLanguage
    private string preferredLanguage;
    public string PreferredLanguage{
        get => preferredLanguage;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value,nameof(PreferredLanguage));
            preferredLanguage = value;
        }
    }
    #endregion
    //TODO: ADD MOTHER TONG
    #region Folders
    private List<Folder> folders ;
    public List<Folder> Folders
    {
        get => folders;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value,nameof(Folders));
            folders = value;
        }
    }
    #endregion
}
