using Microsoft.AspNetCore.Http;

namespace VoCat.SharedKernel
{
    public static class Utils
    {
        public static async Task<string> ConvertToBase64Async(IFormFile imageFile)
    {
            using var memoryStream = new MemoryStream();
            await imageFile.CopyToAsync(memoryStream);
            return Convert.ToBase64String(memoryStream.ToArray());
        }
    }
}