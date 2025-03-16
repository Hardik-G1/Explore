import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtils {
  static double calculateRadius(int zoom) {
    const double baseRadius = 50.0;
    return baseRadius * (zoom / 100.0);
  }

  static bool isLocationClose(LatLng a, LatLng b,
      {double thresholdMeters = 10.0}) {
    const double earthRadiusMeters = 6371000;
    final dLat = (b.latitude - a.latitude) * (math.pi / 180);
    final dLng = (b.longitude - a.longitude) * (math.pi / 180);
    final lat1 = a.latitude * (math.pi / 180);
    final lat2 = b.latitude * (math.pi / 180);

    final aCalc = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) *
            math.sin(dLng / 2) *
            math.cos(lat1) *
            math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(aCalc), math.sqrt(1 - aCalc));
    final distance = earthRadiusMeters * c;

    return distance <= thresholdMeters;
  }
}
