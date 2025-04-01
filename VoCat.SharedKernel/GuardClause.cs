namespace VoCat.SharedKernel;

public static class GuardClause
{
    public static void EnsureNotNullOrEmpty(Guid value, string propertyName)
        {
            if (value == Guid.Empty)
            {
                throw new ArgumentException($"{propertyName} cannot be an empty GUID.");
            }
        }
    public static void EnsureNotNullOrEmpty(string value, string propertyName)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ArgumentException($"{propertyName} cannot be null or empty.");
        }
    }
    public static void EnsureNotNullOrEmpty(DateTime value, string propertyName)
    {
        if (value == DateTime.MinValue)
        {
            throw new ArgumentException($"{propertyName} cannot be the default value.");
        }
    }
    public static void EnsureNotNullOrEmpty(int value, string propertyName)
    {
        if(value == 0) {
            throw new ArgumentNullException($"{propertyName} cannot be the 0.");
        }
    }
    public static void EnsureNotNullOrEmpty<T>(T value, string propertyName) where T : class
    {
        if (value == null)
        {
            throw new ArgumentException($"{propertyName} cannot be null.");
        }
    }

}