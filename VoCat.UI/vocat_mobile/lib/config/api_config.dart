class ApiConfig {
  static const String baseUrl = 'http://localhost:5226/api';
  static const String s3BaseUrl =
      'https://vocatbucket.s3.eu-central-1.amazonaws.com';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'accept': 'text/plain',
  };

  static String getImageUrl(String key) {
    return '$s3BaseUrl/$key';
  }
}
