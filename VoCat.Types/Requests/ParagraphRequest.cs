public class ParagraphRequest
{
    public string PromptType { get; set; }
    public string TargetAudience { get; set; }
    public List<string> VocabList { get; set; }
    public int MaxAttempts { get; set; }
}