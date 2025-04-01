using VoCat.Business.Repository;
using VoCat.SharedKernel;
using VoCat.Types;
using VoCat.Types.Requests;

namespace VoCat.Orchestration;
public class FolderOrchestration
{
    #region Constructor
    private readonly FolderRepository _folderRepository;
    public FolderOrchestration(FolderRepository folderRepository)
    {
        _folderRepository = folderRepository;
    }
    #endregion

    #region Method
    public GenericResult<bool> CreateFolder(FolderRequest request)
    {
        var result = _folderRepository.CreateFolder(request);
        if(request.FolderContract.ParentFolderId !=null)
        {
            UpdateFolder(request); return result;
        }
        return result;
    }

    public GenericResult<List<Folder>?> SelectAllFolders(FolderRequest request)
    {
        var result = _folderRepository.SelectAllFolders(request);
        if (result.Data == null)
        {
            return GenericResult<List<Folder>?>.Failure(GlobalConsts.NoDataFound);
        }
        return result;
    }

    public GenericResult<bool> UpdateFolder(FolderRequest request) 
    {
        var result = _folderRepository.UpdateFolder(request);
        return result;
    }
    #endregion
}