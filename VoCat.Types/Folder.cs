using VoCat.SharedKernel;

namespace VoCat.Types;

public class Folder
{
    public Folder()
    {
        folderId = Guid.NewGuid();
        createdAt = DateTime.UtcNow;
    }

    #region FolderId
    private Guid folderId;
    public Guid FolderId
    {
        get => folderId;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(FolderId));
            folderId = value;
        }
    }
    #endregion
    #region Name
    private string name;
    public string Name{
        get => name;
        set
        {
           GuardClause.EnsureNotNullOrEmpty(value,nameof(Name)); 
           name = value;
        }
    }
    #endregion
    #region ParenFolderId
    private Guid? parentFolderId; 
    public Guid? ParentFolderId
    {
        get => parentFolderId;
        set
        {
            parentFolderId = value;
        }
    }
    #endregion
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
    #region UpdatedAt
    private DateTime? updatedAt;
    public DateTime? UpdatedAt{
        get => updatedAt;
        set
        {
            updatedAt = value;
        }
    }
    #endregion
}
