using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using VoCat.Orchestration;
using VoCat.SharedKernel;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WordController : ControllerBase
    {
        private readonly WordOrchestration _wordOrchestration;

        public WordController(WordOrchestration wordOrchestration)
        {
            _wordOrchestration = wordOrchestration;
        }

        [HttpPost("create")]
        public async Task<bool> CreateWord([FromBody] WordRequest request)
        {
           
            return (await _wordOrchestration.CreateWord(request)).Data;
        }

        [HttpGet("folder/{folderId}")]
        public List<Word>? SelectWordsByFolderId(Guid folderId)
        {
            var request = new WordRequest(new Word { FolderId = folderId });
            return _wordOrchestration.SelectWordsByFolderId(request).Data;
        }

        [HttpGet("{id}")]
        public Word? SelectWordById(Guid id)
        {
            var request = new WordRequest(new Word { WordId = id });
            return _wordOrchestration.SelectWordById(request).Data;
        }

        [HttpPut("update")]
        public async Task<bool> UpdateWordAsync(WordRequest request)
        {
            return (await _wordOrchestration.UpdateWordAsync(request)).Data;
        }

        [HttpPost("generateparagraph")]
        public async Task<string> GenerateParagraph(ParagraphRequest request) 
        {
            return (await _wordOrchestration.GenerateParagraph(request)).Data;
        }
    }
} 