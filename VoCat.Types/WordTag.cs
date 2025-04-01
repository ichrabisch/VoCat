using VoCat.SharedKernel;
using System;

namespace VoCat.Types
{
    public class WordTag
    {
        #region WordId
        private Guid wordId;
        public Guid WordId
        {
            get => wordId;
            set
            {
                GuardClause.EnsureNotNullOrEmpty(value, nameof(WordId));
                wordId = value;
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
