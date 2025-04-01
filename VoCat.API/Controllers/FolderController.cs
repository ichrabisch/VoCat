using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using VoCat.Orchestration;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FolderController : ControllerBase
    {
        private readonly FolderOrchestration _folderOrchestration;
        public FolderController(FolderOrchestration folderOrchestration)
        {
            _folderOrchestration = folderOrchestration;
        }
        [HttpPost("createfolder")]
        public bool CreateFolder(FolderRequest request)
        {
            return _folderOrchestration.CreateFolder(request).Data;
        }
        [HttpGet("selectallfolders")]
        public List<Folder>? SelectAllFolders([FromQuery] Guid userId)
        {
            var contract = new Folder { UserId = userId };
            var request = new FolderRequest ( contract );
            return _folderOrchestration.SelectAllFolders(request).Data;
        }
        [HttpPut("update")]
        public bool UpdateFolder(FolderRequest request)
        {
            return _folderOrchestration.UpdateFolder(request).Data;
        }
    }
}
