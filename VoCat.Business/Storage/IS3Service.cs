using VoCat.SharedKernel;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.Business.Storage
{
    public interface IS3Service
    {
        public Task<GenericResult<string>> UploadWordImageAsync(Guid wordId, Guid userId, byte[] imageBytes, string contentType);
        public Task<GenericResult<string>> UploadWordImageAsync(Guid wordId, Guid userId, Image imageContract);
        public Task<GenericResult<byte[]>> GetWordImageAsync(string fileKey);
    }
}