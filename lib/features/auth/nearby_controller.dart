import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';

// ... NearbyUser model tetap sama

class NearbyController extends ChangeNotifier {
  final DioClient _dioClient = GetIt.instance<DioClient>();

  // ... semua field tetap sama

  Future<void> _updateLocationToServer(double lat, double lng) async {
    await _dioClient.post(
      ApiConstants.nearbyUpdate,
      data: {'lat': lat, 'lng': lng},
    );
  }

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

      final List<dynamic> data = response.data is List
          ? response.data
          : (response.data['data'] ?? []);
      _users = data.map((json) => NearbyUser.fromJson(json)).toList();
    } catch (e) {
      _errorMessage = _handleError(e);
      _users = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... method lainnya tetap sama, hanya pakai _dioClient
}
