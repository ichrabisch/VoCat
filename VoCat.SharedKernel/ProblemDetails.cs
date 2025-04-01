using System.Text.Json.Serialization;

namespace VoCat.SharedKernel;
public class ProblemDetails
{
    [JsonPropertyName("Status")]
    public int Status { get; set; }

    [JsonPropertyName("Title")]
    public string Title { get; set; }

    [JsonPropertyName("Detail")]
    public string Detail { get; set; }
}