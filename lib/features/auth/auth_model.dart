class AuthResponse {
  final String token;
  final UserData user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Ekstraksi token fleksibel (seperti di index.html)
    String? token = json['token'] ?? json['access_token'];
    Map<String, dynamic>? userJson;

    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      token ??= json['data']['token'] ?? json['data']['access_token'];
      userJson = json['data']['user'];
    }
    if (json['result'] != null && json['result'] is Map<String, dynamic>) {
      token ??= json['result']['token'] ?? json['result']['access_token'];
      userJson = json['result']['user'];
    }
    userJson ??= json['user'];

    if (token == null) {
      throw Exception(json['message'] ?? 'Token tidak ditemukan dalam respons');
    }

    return AuthResponse(
      token: token,
      user: UserData.fromJson(userJson ?? {}),
    );
  }
}

class UserData {
  final String guid;
  final String username;
  final String fullname;
  final String email;
  final String gender;
  final String? avatar;
  final bool online;

  UserData({
    required this.guid,
    required this.username,
    required this.fullname,
    required this.email,
    required this.gender,
    this.avatar,
    this.online = false,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      guid: json['guid']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      gender: json['gender']?.toString() ?? 'male',
      avatar: json['avatar']?.toString(),
      online: json['online'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'guid': guid,
        'username': username,
        'fullname': fullname,
        'email': email,
        'gender': gender,
        'avatar': avatar,
        'online': online,
      };
}
