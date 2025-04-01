using VoCat.SharedKernel;
using System;

namespace VoCat.Types
{
    public class FolderTag
    {
        #region FolderId
        private Guid folderId;
        public Guid FolderId
        {
            get => folderId;
            set
            {
                GuardClause.EnsureNotNullOrEmpty(value, nameof(FolderId));
                folderId = value;
            }
        }
        #endregion

        #region TagId
        private Guid tagId;
        public Guid TagId
        {
            get => tagId;
            set
            {
                GuardClause.EnsureNotNullOrEmpty(value, nameof(TagId));
                tagId = value;
            }
        }
        #endregion
    }
}
