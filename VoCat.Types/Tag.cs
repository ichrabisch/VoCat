using System;
using VoCat.SharedKernel;

namespace VoCat.Types;

public class Tag
{
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

        #region Name
        private string name;
        public string Name
        {
            get => name;
            set
            {
                GuardClause.EnsureNotNullOrEmpty(value, nameof(Name));
                name = value;
            }
        }
        #endregion

        #region UserId
        private Guid userId;
        public Guid UserId
        {
            get => userId;
            set
            {
                GuardClause.EnsureNotNullOrEmpty(value, nameof(UserId));
                userId = value;
            }
        }
        #endregion

        #region CreatedAt
        private DateTime createdAt;
        public DateTime CreatedAt
        {
            get => createdAt;
            set
            {
                GuardClause.EnsureNotNullOrEmpty(value, nameof(CreatedAt));
                createdAt = value;
            }
        }
        #endregion
}
