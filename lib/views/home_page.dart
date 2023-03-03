import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_line_editor/dragmarker.dart';
import 'package:flutter_map_line_editor/polyeditor.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:app_pengukur_lahan/controllers/home_page_controller.dart';
import 'package:app_pengukur_lahan/utils/hitung_map.dart';
import 'package:app_pengukur_lahan/views/widgets/anchored_overlay.dart';
import 'package:app_pengukur_lahan/views/widgets/pab_icons.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final HitungMap hitungMap = HitungMap();
  final MapController _mapController = MapController();
  late PolyEditor polyEditor;
  late LatLng _markerManual = LatLng(0.0, 0.0);
  final List<Polygon> _polygons = [];
  final Polygon _poly = Polygon(
      color: Colors.amber.withOpacity(0.7),
      borderColor: Colors.grey.shade800,
      borderStrokeWidth: 4.0,
      isDotted: true,
      isFilled: true,
      points: []);

  String _lastSelected = 'TAB: 0';
  final List<IconData> icons = [Icons.delete_outline, Icons.undo, Icons.add];
  late AnimationController _controller;
  late Animation<double> _animation;
  double _area = 0.0;

  @override
  void initState() {
    // TODO: implement initState

    _controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    polyEditor = PolyEditor(
      addClosePathMarker: true,
      points: _poly.points,
      pointIcon: Icon(
        Icons.adjust,
        size: 32.0,
        color: Colors.grey.shade800,
      ),
      intermediateIcon:
          Icon(Icons.adjust, size: 20.0, color: Colors.grey.shade800),
      callbackRefresh: () {
        setState(() {
          _area = hitungMap.kalkulasiArea(_poly.points);
        });
      },
    );

    _polygons.add(_poly);

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  void _selectedFab(int index) {
    setState(() {
      _lastSelected = 'FAB: $index';
    });
  }

  void _addPolygon({required LatLng latLng, required Position? currentPos}) {
    if (latLng.latitude == 0.0 && latLng.longitude == 0.0) {
      if (currentPos != null) {
        setState(() {
          polyEditor.add(
              _poly.points, LatLng(currentPos.latitude, currentPos.longitude));
        });
      }
    } else {
      setState(
        () {
          polyEditor.add(_poly.points, latLng);
        },
      );
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
        begin: _mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: _mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.zoom, end: destZoom);
    final controller = AnimationController(
        duration: const Duration(milliseconds: 250), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light));
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        title: Text(
          "GPS Pengukur Area",
          style: TextStyle(
            color: Colors.grey.shade800,
          ),
        ),
        backgroundColor: Colors.amber,
      ),
      body: GetX<HomePageController>(
        init: HomePageController(),
        initState: (_) {},
        builder: (_) {
          return Stack(
            children: [
              _.currentPos != null
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                          absorbPanEventsOnScrollables: false,
                          center: LatLng(
                              _.currentPos!.latitude, _.currentPos!.longitude),
                          onPositionChanged:
                              (MapPosition position, bool hasGesture) {
                            if (hasGesture) {
                              _.centerOnLocationUpdate =
                                  CenterOnLocationUpdate.never;
                              _markerManual = position.center!;
                            }
                          },
                          onTap: ((tapPosition, point) {
                            setState(() {});
                          }),
                          maxZoom: 18.0),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                          userAgentPackageName:
                              "com.example.app_pengukur_lahan",
                        ),
                        CurrentLocationLayer(
                          centerOnLocationUpdate: _.centerOnLocationUpdate,
                        ),
                        PolygonLayer(
                          polygons: _polygons,
                        ),
                        DragMarkers(
                          markers: polyEditor.edit(),
                        )
                      ],
                    )
                  : const Center(
                      child: CircularProgressIndicator(),
                    ),
              _.currentPos != null
                  ? const Center(
                      child: Icon(Icons.add, color: Colors.red, size: 32.0),
                    )
                  : Container(),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ScaleTransition(
                    scale: _animation,
                    child: Material(
                      elevation: 2.0,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(20.0)),
                      child: Container(
                        width: 200.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0))),
                        child: Center(
                            child: Text(
                          "${_area.abs().toStringAsFixed(2)} m\u00B2",
                          style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 25.0, 25.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    heroTag: "btnCurrentGps",
                      backgroundColor: Colors.amber,
                      elevation: 2.0,
                      shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      child: Icon(
                        Icons.location_searching,
                        color: Colors.grey.shade800,
                      ),
                      onPressed: () {
                        if (_.currentPos != null) {
                          _animatedMapMove(
                              LatLng(_.currentPos!.latitude,
                                  _.currentPos!.longitude),
                              18.0);
                          _.centerOnLocationUpdate =
                              CenterOnLocationUpdate.always;
                        }
                      }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(25.0, 0.0, 0.0, 25.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: AnchoredOverlay(
                    showOverlay: true,
                    overlayBuilder: (context, offset) {
                      return CenterAbout(
                        position:
                            Offset(offset.dx, offset.dy - icons.length * 35.0),
                        child: FabIcons(
                          icons: icons,
                          onIconTapped: _selectedFab,
                          onPressed: (index) {
                            switch (index) {
                              case 0:
                                print("clear");
                                setState(() {
                                  if (_poly.points.isNotEmpty) {
                                    _poly.points.clear();
                                    _area = 0.0;
                                  }
                                  _controller.animateBack(0.0);
                                });
                                break;
                              case 1:
                                print("undo");
                                setState(() {
                                  if (_poly.points.length > 1) {
                                    _poly.points.removeLast();
                                    _area =
                                        hitungMap.kalkulasiArea(_poly.points);
                                  }
                                  if (_poly.points.length < 2) {
                                    _controller.animateBack(0.0);
                                  }
                                });
                                break;
                              case 2:
                                print("add");
                                _addPolygon(
                                    latLng: _markerManual,
                                    currentPos: _.currentPos);
                                setState(
                                  () {
                                    _area =
                                        hitungMap.kalkulasiArea(_poly.points);
                                    if (_poly.points.length > 2) {
                                      _controller.animateTo(1.0);
                                    }
                                  },
                                );
                                break;
                              default:
                            }
                          },
                        ),
                      );
                    },
                    child: FloatingActionButton(
                      heroTag: "btnMenu",
                      backgroundColor: Colors.amber,
                      elevation: 2.0,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      onPressed: () {},
                      child: Icon(Icons.menu, color: Colors.grey.shade800),
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
