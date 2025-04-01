namespace VoCat.Types.Requests
{
    public class WordRequest
    {
        public Word WordContract { get; private set; }
        public Image? ImageContract { get; private set; }
        public WordRequest(Word wordContract, Image? imageContract = null)
        {
            WordContract = wordContract;
            ImageContract = imageContract;
        }
        public void SetImageContract(Image imageContract)
        {
            ImageContract = imageContract;
        }
       
    }
}
