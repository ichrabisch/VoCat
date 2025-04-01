using Amazon;
using Amazon.Runtime;
using Amazon.S3;
using Amazon.S3.Model;
using VoCat.SharedKernel;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.Business.Storage
{
    public class S3Service : IS3Service
    {
        private readonly IAmazonS3 _s3Client;
        private readonly string _bucketName;

        public S3Service(string accessKey, string secretKey, string bucketName, string region = "eu-central-1")
        {
            var credentials = new BasicAWSCredentials(accessKey, secretKey);
            var config = new AmazonS3Config
            {
                RegionEndpoint = RegionEndpoint.GetBySystemName(region)
            };

            _s3Client = new AmazonS3Client(credentials, config);
            _bucketName = bucketName;
        }

        public async Task<GenericResult<string>> UploadWordImageAsync(Guid wordId, Guid userId, byte[] imageBytes, string contentType)
        {
            try
            {
                var fileKey = $"word-images/{userId}/{wordId}.jpg";
                using var memoryStream = new MemoryStream(imageBytes);

                var putRequest = new PutObjectRequest
                {
                    BucketName = _bucketName,
                    Key = fileKey,
                    InputStream = memoryStream,
                    ContentType = contentType,
                    CannedACL = S3CannedACL.Private
                };
                await _s3Client.PutObjectAsync(putRequest);
                return GenericResult<string>.Success(fileKey);
            }
            catch (Exception)
            {
                return GenericResult<string>.Failure(GlobalConsts.UploadImageError);
            }
        }

        public async Task<GenericResult<string>> UploadWordImageAsync(Guid wordId, Guid userId, Image imageContract)
        {
            var base64Image = imageContract.Base64Image;
            var base64Data = base64Image.Contains(",") ?
                base64Image.Substring(base64Image.IndexOf(",") + 1) : base64Image;

            var imageBytes = Convert.FromBase64String(base64Data);
            var response = (await UploadWordImageAsync(wordId,userId, imageBytes, "image/jpeg")).Data;

            if(response == null)
            {
                return GenericResult<string>.Failure(GlobalConsts.NoDataFound);
            }

            return GenericResult<string>.Success(response);
        }

        public async Task<GenericResult<byte[]>> GetWordImageAsync(string fileKey)
        {
            try
            {
                var response = await _s3Client.GetObjectAsync(_bucketName, fileKey);
                using var memoryStream = new MemoryStream();
                await response.ResponseStream.CopyToAsync(memoryStream);
                return GenericResult<byte[]>.Success(memoryStream.ToArray());
            }
            catch (AmazonS3Exception ex)
            {
                if (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
                    return GenericResult<byte[]>.Failure(GlobalConsts.NoDataFound);
                return GenericResult<byte[]>.Failure(ex.Message);
            }
        }
    }
}
