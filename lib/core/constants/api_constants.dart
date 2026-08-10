abstract class ApiConstants {
  // 🔧 Ganti ke server produksi ChatTeman
  static const String baseUrl = 'https://yayanheeh.my.id/chatapi/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String checkUsername = '/auth/check-username';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
}
