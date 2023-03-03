import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomePageController extends GetxController {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.best,
  );
  late StreamSubscription<Position> _streamPosition;
  final _currentPos = Rx<Position?>(null);
  final _centerOnLocationUpdate =
      Rx<CenterOnLocationUpdate>(CenterOnLocationUpdate.always);

  // getters
  CenterOnLocationUpdate get centerOnLocationUpdate =>
      _centerOnLocationUpdate.value;
  Position? get currentPos => _currentPos.value;

  // setters
  set centerOnLocationUpdate(val) {
    _centerOnLocationUpdate.value = val;
  }

  @override
  void onInit() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Warning", "Harap aktifkan Layanan Lokasi Anda");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Warning", "Izin lokasi ditolaked");
        SystemNavigator.pop();
      }
    }


    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Warning",
          "Izin lokasi ditolak secara permanen, kami tidak dapat meminta izin.");
      SystemNavigator.pop();
    }

    _streamPosition =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) async {
      if (position != null) {
        _currentPos.value = position;

      } else {
        Get.snackbar("Warning", "Tidak dapat menemukan lokasi");
      }
    });

    super.onInit();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _streamPosition.cancel();
    super.dispose();
  }
}
