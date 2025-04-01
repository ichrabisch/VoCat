using System.Net;
using System.Text.Json.Serialization;

namespace VoCat.SharedKernel;
public class GenericResult<T>
{
    #region Constructor
    private GenericResult() : this(true)
    { }

    private GenericResult(bool isSuccess)
    { 
        IsSuccess = isSuccess; 
        if (!isSuccess) 
        {
            Data = default;
        }
    }
    #endregion

    #region Property
    [JsonPropertyName("IsSuccess")] 
    public bool IsSuccess { get; init; }
    
    [JsonPropertyName("Data")] 
    public T? Data { get; private init; }
    
    [JsonPropertyName("ProblemDetails")] 
    public ProblemDetails ProblemDetails { get; private init; } = new();

    public static GenericResult<T> Success(T data)
    {
        return new GenericResult<T>(true)
        {
            Data = data
        };
    }

    public static GenericResult<T> Failure(string message)
    {
        return new GenericResult<T>(false)
        {
            ProblemDetails = new ProblemDetails{
                Status = (int)HttpStatusCode.BadRequest,
                Title = GlobalConsts.CreateErrorTitle,
                Detail = message
            }
        };
    }

    public static GenericResult<T> Exception(ProblemDetails problemDetails)
    {
        return new GenericResult<T>(false)
        {
            ProblemDetails = problemDetails
        };
    }
    #endregion
    
}