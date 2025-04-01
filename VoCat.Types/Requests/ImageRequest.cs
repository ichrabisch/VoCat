namespace VoCat.Types.Requests
{
    public class ImageRequest
    {
        public Image ImageContract { get; private set; }
        public ImageRequest(Image imageContract)
        {
            ImageContract = imageContract;
        }
    }
}

