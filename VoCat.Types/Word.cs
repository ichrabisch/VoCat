using System;
using VoCat.SharedKernel;

namespace VoCat.Types;

public class Word
{
    public Word()
    {
        wordId = Guid.NewGuid();
        createdAt = DateTime.UtcNow;
    }

    #region WordId
    private Guid wordId;
    public Guid WordId
    {
        get => wordId;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(WordId));
            wordId = value;
        }
    }
    #endregion
    #region WordText
    private string wordText;
    public string WordText
    {
        get => wordText;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(WordText));
            wordText = value;
        }
    }
    #endregion
    #region Translation
    private string translation;
    public string Translation
    {
        get => translation;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(Translation));
            translation = value;
        }
    }
    #endregion
    #region Definition
    private string? definition;
    public string? Definition
    {
        get => definition;
        set
        {
            definition = value;
        }
    }
    #endregion
    #region ExampleSentence
    private string? exampleSentence;
    public string? ExampleSentence
    {
        get => exampleSentence;
        set
        {
            exampleSentence = value;
        }
    }
    #endregion
    #region ImageUrl
    private string? imageUrl;
    public string? ImageUrl
    {
        get => imageUrl;
        set
        {
            imageUrl = value;
        }
    }
    #endregion
    #region AudioFileUrl
    private string? audioFileUrl;
    public string? AudioFileUrl
    {
        get => audioFileUrl;
        set
        {
            audioFileUrl = value;
        }
    }
    #endregion
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
    public DateTime CreatedAt
    {
        get => createdAt;
        set
        {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(CreatedAt));
            createdAt = value;
        }
    }
    #endregion
    #region UpdatedAt
    private DateTime? updatedAt;
    public DateTime? UpdatedAt
    {
        get => updatedAt;
        set
        {
            updatedAt = value;
        }
    }
    #endregion
    #region MasteryLevel
    private int masteryLevel;
    public int MasteryLevel
    {
        get => masteryLevel; 
        set {
            GuardClause.EnsureNotNullOrEmpty(value, nameof(MasteryLevel));
            masteryLevel = value;
        }
    }
    #endregion
    #region LastReviewed
    private DateTime? lastReviewed;
    public DateTime? LastReviewed
    {
        get => lastReviewed;
        set
        {
            lastReviewed = value;
        }
    }
    #endregion
    #region IsFromRecognition
    private bool isFromRecognition;
    public bool IsFromRecognition
    {
        get => isFromRecognition;
        set
        {
            isFromRecognition = value;
        }
    }
    #endregion
}
