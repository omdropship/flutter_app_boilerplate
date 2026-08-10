import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔧 Pastikan package ini ada di pubspec.yaml
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';
import 'auth_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  /// Login dengan username/email dan password
  Future<AuthResponse> login(String username, String password) async {
    final response = await DioClient.instance.post(
      ApiConstants.login,
      data: {
        'username': username,
        'password': password,
      },
    );

    final authResponse = AuthResponse.fromJson(response.data);

    // Simpan token dan user
    await saveToken(authResponse.token);
    await saveUser(authResponse.user);

    // Set token di DioClient untuk request selanjutnya
    DioClient.instance.setAuthToken(authResponse.token);

    return authResponse;
  }

  /// Logout
  Future<void> logout() async {
    // Hapus token dari penyimpanan
    await deleteToken();
    await deleteUser();
    // Hapus dari DioClient
    DioClient.instance.clearAuthToken();
  }

  /// Cek apakah user sudah login (token tersimpan)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token != null) {
      DioClient.instance.setAuthToken(token); // pasang token di client
      return true;
    }
    return false;
  }

  /// Ambil token dari penyimpanan
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

  /// Ambil data user dari penyimpanan
  Future<UserData?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserData.fromJson(
        Map<String, dynamic>.from(
          // decode JSON, misal pakai dart:convert
          // Karena kita simpan sebagai string JSON
          // Sederhananya: gunakan jsonDecode
          _decodeJson(userJson),
        ),
      );
    }
    return null;
  }

  Future<void> saveUser(UserData user) async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan sebagai JSON string
    await prefs.setString(_userKey, _encodeJson(user.toJson()));
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Helper JSON
  Map<String, dynamic> _decodeJson(String jsonString) {
    // Gunakan dart:convert
    import 'dart:convert';
    return jsonDecode(jsonString);
  }

  String _encodeJson(Map<String, dynamic> map) {
    import 'dart:convert';
    return jsonEncode(map);
  }
}
