using VoCat.Business;
using VoCat.Types.Requests;
using VoCat.Types;
using VoCat.SharedKernel;
using VoCat.Business.Storage;
using System.Net.Http.Json;

namespace VoCat.Orchestration;
public class WordOrchestration
{
    #region Constructor
    private readonly WordRepository _wordRepository;
    private readonly S3Service _s3Service;
    private readonly string _aiServiceUrl = "http://localhost:8000";
    private readonly HttpClient _httpClient;
    public WordOrchestration(WordRepository wordRepository, S3Service s3Service)
    {
        _wordRepository = wordRepository;
        _s3Service = s3Service;
        _httpClient = new HttpClient();
    }
    #endregion

    #region Method
    public async Task<GenericResult<bool>> CreateWord(WordRequest request)
    {
        var result = _wordRepository.CreateWord(request);

        if (request.ImageContract != null && result.Data)
        {
            var imageUrl = (await _s3Service.UploadWordImageAsync(request.WordContract.WordId, request.WordContract.UserId, request.ImageContract)).Data;
            var updateRequest = new WordRequest(new Word { WordId = request.WordContract.WordId, FolderId=request.WordContract.FolderId, ImageUrl = imageUrl });
            result = _wordRepository.UpdateWord(updateRequest);
        }
        return result;
    }

    public GenericResult<List<Word>?> SelectWordsByFolderId(WordRequest request)
    {
        var result = _wordRepository.SelectWordsByFolderId(request);
        if (result.Data == null)
        {
            return GenericResult<List<Word>?>.Failure(GlobalConsts.NoDataFound);
        }
        return result;
    }

    public GenericResult<Word?> SelectWordById(WordRequest request)
    {
        var result = _wordRepository.SelectWordById(request);
        return result;
    }

    public async Task<GenericResult<bool>> UpdateWordAsync(WordRequest request)
    {
        if (request.ImageContract != null)
        {
            var imageUrl = (await _s3Service.UploadWordImageAsync(request.WordContract.WordId, request.WordContract.UserId, request.ImageContract)).Data;
            request.WordContract.ImageUrl = imageUrl;
        }
        var result = _wordRepository.UpdateWord(request);

        return result;
    }
    public async Task<GenericResult<string>> GenerateParagraph(ParagraphRequest request)
    {
        Dictionary<string, object> jsonDict = new Dictionary<string, object>();
        jsonDict["prompt_type"] = request.PromptType;
        jsonDict["target_audience"] = request.TargetAudience;
        jsonDict["vocab_list"] = request.VocabList;
        jsonDict["max_attempts"] = request.MaxAttempts;

        var response = await _httpClient.PostAsJsonAsync(_aiServiceUrl + "/generate_paragraph", jsonDict);
        if(response.IsSuccessStatusCode)
        {
            return GenericResult<string>.Success(response.Content.ReadAsStringAsync().Result);
        }
        return GenericResult<string>.Failure(GlobalConsts.ParagraphGenerationError);
    }
    #endregion
}
