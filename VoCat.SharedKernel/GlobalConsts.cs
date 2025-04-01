namespace VoCat.SharedKernel
{
    public static class GlobalConsts
    {
        public static readonly int CreateError = -1;
        public static readonly string CreateErrorTitle = "Operation failed!";
        public static readonly string InternalServerErrorTitle = "Internal server error!";
        public static readonly string WrongCredentials = "Check your email or password!";
        public static readonly string NoDataFound = "No data found!";
        public static readonly string UploadImageError = "Uploading image was failed!";
        public static readonly string AWSConfigurationError = "AWS configuration is missing or invalid.";
        public static readonly string ParagraphGenerationError = "An error has occured while generating paragraph.";
        public enum MasteryLevel
        {
            NeedsDailyPractice = 1,    //Just learned, needs daily review
            LearningBasics = 2,        //Daily review
            Recognizing = 3,           //Every 2 days review
            Remembering = 4,           //Every 3 days review
            Understanding = 5,         //Weekly review
            Confident = 6,             //Longer interval
            WellKnown = 7,             //Very long interval
            Mastered = 8               //Fully learned
        }
    }
}
