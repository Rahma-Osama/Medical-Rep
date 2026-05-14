import 'package:geolocator/geolocator.dart';

class ValidateLocationUseCase {
  final double radiusInMeters;

  ValidateLocationUseCase({this.radiusInMeters = 100});

  bool call({
    required double userLat,
    required double userLng,
    required double clinicLat,
    required double clinicLng,
  }) {
    final distance = Geolocator.distanceBetween(
      userLat,
      userLng,
      clinicLat,
      clinicLng,
    );

    return distance <= radiusInMeters;
  }
}