using VoCat.SharedKernel;

namespace VoCat.Types
{
    public class Image
    {
        #region Base64Image
        private string base64Image;
        public string Base64Image {
            get => base64Image;
            set 
            {
                GuardClause.EnsureNotNullOrEmpty(value, nameof(base64Image));
                base64Image = value;
            }
        }
        #endregion
        
    }
}
