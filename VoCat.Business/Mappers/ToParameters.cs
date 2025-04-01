namespace VoCat.Business.Mappers
{
    public static partial class Mapper
    {
        public static Dictionary<string, object> ToParameters<T>(T request)
        {
            Dictionary<string, object> parameters = new Dictionary<string, object>();
            var contractName = request.GetType().GetProperties()[0].Name;
            var propertyInfo = request.GetType().GetProperty(contractName);
            foreach (var property in propertyInfo.PropertyType.GetProperties())
            {
                var value = property.GetValue(propertyInfo.GetValue(request));
               
                var key = "@p_" + ToSnakeCase(property.Name);
                parameters.Add(key, value);
                
            }

            // Always ensure updated_at is set
            if (!parameters.ContainsKey("@p_updated_at"))
            {
                parameters.Add("@p_updated_at", DateTime.UtcNow);
            }

            return parameters;
        }

        private static string ToSnakeCase(string input)
        {
            //UserName
            //result = u
            if (string.IsNullOrEmpty(input)) return input;
            var result = new System.Text.StringBuilder();
            result.Append(ConvertSpecialCharacter(char.ToLower(input[0]))); 

            for (int i = 1; i < input.Length; i++)
            {
                var currentChar = input[i];
                if (char.IsUpper(currentChar) && char.IsLetter(currentChar))
                {
                    result.Append('_');
                    result.Append(ConvertSpecialCharacter(char.ToLower(currentChar)));
                }
                else if (!char.IsLetter(currentChar) && !char.IsDigit(currentChar))
                {
                    result.Append('_');
                }
                else
                {
                    result.Append(ConvertSpecialCharacter(char.ToLower(currentChar)));
                }
            }

            return System.Text.RegularExpressions.Regex.Replace(
                result.ToString(),
                "_+",
                "_"
            );
        }

        private static char ConvertSpecialCharacter(char c)
        {
            return c switch
            {
                'ı' => 'i',
                'İ' => 'i',
                _ => c
            };
        }
    }
}