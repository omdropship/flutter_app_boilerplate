abstract class ApiConstants {
  // 🔧 Ganti ke server produksi ChatTeman
  static const String baseUrl = 'https://yayanheeh.my.id/chatapi/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String checkUsername = '/auth/check-username';

  // Nearby
  static const String nearbyUpdate = '/nearby/update';
  static const String nearbyList = '/nearby/list';

  // Profile
  static const String profileShow = '/profile/show';
  static const String profileEdit = '/profile/edit';
  static const String uploadAvatar = '/upload/avatar';

  // Friends
  static const String friendsList = '/friends/list';
  static const String friendsAdd = '/friends/add';
  static const String friendsRemove = '/friends/remove';
  static const String friendsRequests = '/friends/requests';
  static const String friendsSent = '/friends/sent';

  // Block
  static const String blockAdd = '/block/add';
  static const String blockRemove = '/block/remove';
  static const String blockList = '/block/list';

  // Messages (badge unread)
  static const String messagesList = '/messages/list';
  static const String messagesConversation = '/messages/conversation';
  static const String messagesSend = '/messages/send';

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
