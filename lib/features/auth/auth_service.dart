import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import 'auth_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // Ambil DioClient dari GetIt (jika sudah terdaftar) atau langsung singleton
  final DioClient _dioClient = GetIt.instance.isRegistered<DioClient>()
      ? GetIt.instance<DioClient>()
      : DioClient.instance;

  /// Login dengan username/email dan password
  Future<AuthResponse> login(String username, String password) async {
    final response = await _dioClient.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);

    await saveToken(authResponse.token);
    await saveUser(authResponse.user);

    _dioClient.setAuthToken(authResponse.token);

    return authResponse;
  }

  /// Register user baru, lalu auto-login
  Future<AuthResponse> register({
    required String fullname,
    required String username,
    required String email,
    required String password,
    required String gender,
    required String birthdate,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.register,
      data: {
        'firstname': fullname,
        'username': username,
        'email': email,
        'gender': gender,
        'birthdate': birthdate,
        'password': password,
      },
    );

    final Map<String, dynamic> data = response.data;
    if (data['success'] == true || data['status'] == 'success') {
      return login(username, password);
    } else {
      throw Exception(data['message'] ?? 'Pendaftaran gagal');
    }
  }

  /// Cek ketersediaan username
  Future<bool> checkUsername(String username) async {
    final response = await _dioClient.get(
      ApiConstants.checkUsername,
      queryParameters: {'username': username},
    );
    final data = response.data;
    if (data is Map) {
      return data['data']?['available'] == true;
    }
    return false;
  }

  /// Logout
  Future<void> logout() async {
    await deleteToken();
    await deleteUser();
    _dioClient.clearAuthToken();
  }

  /// Cek apakah user sudah login (token tersimpan)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null) {
      _dioClient.setAuthToken(token);
      return true;
    }
    return false;
  }

  /// Ambil token dari SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Ambil data user dari SharedPreferences
  Future<UserData?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final Map<String, dynamic> map = jsonDecode(userJson);
      return UserData.fromJson(map);
    }
    return null;
  }

  Future<void> saveUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_userKey, jsonString);
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
