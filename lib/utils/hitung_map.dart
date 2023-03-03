import 'dart:math';

import 'package:latlong2/latlong.dart';

class HitungMap {
  final double _radiusBumi = 6371009.0;

  double kalkulasiArea(List<LatLng> patch) {
    final double radius = _radiusBumi;
    final LatLng prev = patch.last;
    double prevTanLat = tan((pi / 2 - _toRadians(prev.latitude)) / 2);
    double prevLng = _toRadians(prev.longitude);

    final double total = patch.fold(0.0, (val, point) {
      final double tanLat = tan((pi / 2 - _toRadians(point.latitude)) / 2);
      final double lng = _toRadians(point.longitude);

      val += _triangleArea(tanLat, lng, prevTanLat, prevLng);

      prevTanLat = tanLat;
      prevLng = lng;

      return val;
    });
    return total * (radius * radius);
  }

  static _toRadians(num degrees) {
    return degrees / 180.0 * pi;
  }

  static _triangleArea(num tan1, num lng1, num tan2, num lng2) {
    final num deltaLng = lng1 - lng2;
    final num t = tan1 * tan2;
    return 2 * atan2(t * sin(deltaLng), 1 + t * cos(deltaLng));
  }
}
