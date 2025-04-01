using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VoCat.Types.Requests
{
    public class FolderRequest
    {
        public Folder FolderContract { get; private set; }
        public FolderRequest(Folder folderContract) {
            FolderContract = folderContract;
        }
    }
}
