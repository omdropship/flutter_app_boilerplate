import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_client.dart';

// ---------- MODEL NEARBY USER ----------
class NearbyUser {
  final String guid;
  final String username;
  final String fullname;
  final String? avatar; // URL utama (sudah di-resolve)
  final String? profileUrl;
  final bool online;
  final String gender;
  final String? bio;
  final double distance; // dalam km
  final int age;

  NearbyUser({
    required this.guid,
    required this.username,
    required this.fullname,
    this.avatar,
    this.profileUrl,
    required this.online,
    required this.gender,
    this.bio,
    required this.distance,
    required this.age,
  });

  factory NearbyUser.fromJson(Map<String, dynamic> json) {
    // Resolve avatar: prioritas large → larger → small → smaller → topbar
    String? avatarUrl;
    final avatarField = json['avatar'];
    if (avatarField is Map) {
      avatarUrl = avatarField['large'] ??
          avatarField['larger'] ??
          avatarField['small'] ??
          avatarField['smaller'] ??
          avatarField['topbar'];
    } else if (avatarField is String) {
      avatarUrl = avatarField;
    }

    return NearbyUser(
      guid: json['guid']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullname: json['fullname']?.toString() ?? '',
      avatar: avatarUrl,
      profileUrl: json['profile_url']?.toString(),
      online: json['online'] == true,
      gender: json['gender']?.toString() ?? 'all',
      bio: json['bio']?.toString(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      age: (json['age'] as num?)?.toInt() ?? 0,
    );
  }
}

// ---------- CONTROLLER ----------
class NearbyController extends ChangeNotifier {
  // Ambil DioClient dari GetIt (jika sudah terdaftar) atau langsung singleton
  final DioClient _dioClient = GetIt.instance.isRegistered<DioClient>()
      ? GetIt.instance<DioClient>()
      : DioClient.instance;

  List<NearbyUser> _users = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialLoading = true;

  double? _lastLatitude;
  double? _lastLongitude;
  double _radius = 25;
  String _gender = 'all';
  int _minAge = 18;
  int _maxAge = 60;
  int _unreadCount = 0;

  // Getters
  List<NearbyUser> get users => _users;
  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  String? get errorMessage => _errorMessage;
  double get radius => _radius;
  String get gender => _gender;
  int get minAge => _minAge;
  int get maxAge => _maxAge;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;
  int get unreadCount => _unreadCount;

  /// Langkah awal: GPS → update server → ambil daftar → badge
  Future<void> loadNearby() async {
    _isInitialLoading = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _determinePosition();
      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;

      await _updateLocationToServer(_lastLatitude!, _lastLongitude!);
      await fetchNearbyList();
      await _fetchUnreadCount();
    } catch (e) {
      _errorMessage = _handleError(e);
    } finally {
      _isLoading = false;
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  /// Minta izin lokasi & dapatkan posisi
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak. Aktifkan izin lokasi untuk menemukan pengguna di sekitar kamu.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak secara permanen. Buka pengaturan aplikasi.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  /// POST /nearby/update
  Future<void> _updateLocationToServer(double lat, double lng) async {
    await _dioClient.post(
      ApiConstants.nearbyUpdate,
      data: {'lat': lat, 'lng': lng},
    );
  }

  /// GET /nearby/list dengan filter saat ini
  Future<void> fetchNearbyList() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      if (_lastLatitude == null || _lastLongitude == null) {
        throw Exception('Lokasi belum tersedia. Silakan refresh.');
      }

      final response = await _dioClient.get(
        ApiConstants.nearbyList,
        queryParameters: {
          'lat': _lastLatitude.toString(),
          'lng': _lastLongitude.toString(),
          'radius': _radius.toInt().toString(),
          'gender': _gender,
          'min_age': _minAge.toString(),
          'max_age': _maxAge.toString(),
        },
      );

      // Response bisa berupa List atau { data: List }
      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      _users = data.map((json) => NearbyUser.fromJson(json)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _handleError(e);
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// GET /messages/list untuk badge unread
  Future<void> _fetchUnreadCount() async {
    try {
      final response = await _dioClient.get(ApiConstants.messagesList);
      _unreadCount = (response.data?['unread_total'] as int?) ?? 0;
    } catch (_) {
      _unreadCount = 0;
    }
    notifyListeners();
  }

  /// Pull-to-refresh: coba update lokasi & ambil data
  Future<void> refresh() async {
    try {
      final position = await _determinePosition();
      _lastLatitude = position.latitude;
      _lastLongitude = position.longitude;
      await _updateLocationToServer(_lastLatitude!, _lastLongitude!);
    } catch (_) {
      // Jika gagal update, tetap gunakan koordinat terakhir
    }
    await fetchNearbyList();
    await _fetchUnreadCount();
  }

  /// Terapkan filter tanpa minta GPS ulang
  void applyFilter({
    required double radius,
    required String gender,
    required int minAge,
    required int maxAge,
  }) {
    _radius = radius;
    _gender = gender;
    _minAge = minAge;
    _maxAge = maxAge;
    fetchNearbyList(); // langsung fetch dengan filter baru
  }

  /// Reset filter ke default
  void resetFilter() {
    _radius = 25;
    _gender = 'all';
    _minAge = 18;
    _maxAge = 60;
    fetchNearbyList();
  }

  /// Konversi error ke pesan user-friendly
  String _handleError(dynamic error) {
    final String msg = error.toString();
    if (msg.contains('401')) {
      return 'Silakan login kembali.';
    } else if (msg.contains('SocketException') || msg.contains('Timeout')) {
      return 'Gagal terhubung ke server. Periksa koneksi internet.';
    } else if (msg.contains('Izin lokasi') || msg.contains('GPS')) {
      return 'Aktifkan izin lokasi untuk menemukan pengguna di sekitar kamu.';
    } else {
      return 'Gagal mengambil data terdekat.';
    }
  }
}
