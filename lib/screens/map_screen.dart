import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:hello_world/utils/map_utils.dart';
import '../providers/custom_tile_provider.dart';
import '../services/background_location_service.dart';
import '../services/storage_service.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng initialLocation = const LatLng(55.943495, -3.183296);
  double zoom = 12;
  String? _mapStyle;
  bool _mapLoaded = false;
  bool linesOn = false;
  bool showHeader = true;
  bool _permissionsGranted = false;

  String tileID = "CustomMask";
  int tileCounter = 0;
  bool hideMap = true;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LocationService? _locationService;
  DateTime _selectedDate = DateTime.now();
  StorageService? _storageService;
  bool _isCalendarVisible = false;
  Set<LatLng> visitedAreas = {};
  final List<Polyline> _polylinesList = [
    Polyline(
      polylineId: PolylineId('route1'),
      points: [],
      color: Colors.blue,
      width: 7,
    ),
  ];
  DateTime _currentMonth = DateTime.now();
  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    List<DateTime> daysInMonth = [];

    for (int i = 0; i <= lastDayOfMonth.day - 1; i++) {
      daysInMonth.add(firstDayOfMonth.add(Duration(days: i)));
    }
    return daysInMonth;
  }

  // Function to handle month navigation (next and previous)
  void _navigateMonth(bool isNext) {
    setState(() {
      if (isNext) {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      } else {
        _currentMonth =
            DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      }
    });
  }

  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  Future<void> _loadMapStyle() async {
    try {
      _mapStyle = await rootBundle.loadString('assets/styles.json');
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  void _initializePolylines() {
    _polylines.addAll(_polylinesList);
  }

  void _updateLocation(bg.Location location) {
    final newLocation =
        LatLng(location.coords.latitude, location.coords.longitude);
    debugPrint("[MOUNTED DETAILS]: $mounted");
    if (mounted) {
      setState(() {
        initialLocation = newLocation;
        if (visitedAreas.isEmpty ||
            !MapUtils.isLocationClose(visitedAreas.last, newLocation)) {
          //will be a problem in large system
          if (linesOn) {
            _polylinesList.first.points.add(newLocation);
          }
          visitedAreas.add(newLocation);
          tileID = DateTime.now().millisecondsSinceEpoch.toString();
          _mapController?.animateCamera(CameraUpdate.newLatLng(newLocation));
          _storageService?.saveVisitedLocation(newLocation);
        }
      });
    }
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize storage service
      _storageService = await StorageService.initialize();

      // Initialize location service with a callback for location updates
      _locationService = LocationService(onLocationChanged: _updateLocation);

      await _locationService?.initialize();

      // Get the current location and update the UI
      final location = await _locationService?.getCurrentLocation();
      if (location != null && mounted) {
        setState(() {
          initialLocation =
              LatLng(location.coords.latitude, location.coords.longitude);
        });
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  Future<void> _loadVisitedAreas() async {
    if (_storageService != null) {
      setState(() {
        visitedAreas = _storageService!.getVisitedLatLng();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    tileID = DateTime.now().millisecondsSinceEpoch.toString();
    _checkPermissionsAndInitialize();
    _initializeMapRenderer();
    _loadMapStyle();
    //_initializeServices().then((_) => _loadVisitedAreas());
    _initializePolylines();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    // Request necessary permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationAlways,
      Permission.activityRecognition,
    ].request();

    if (statuses[Permission.locationAlways]?.isGranted ?? false) {
      if (statuses[Permission.activityRecognition]?.isGranted ?? false) {
        // Permissions granted
        setState(() {
          _permissionsGranted = true;
        });
        _initializeServices().then((_) => _loadVisitedAreas());
      }
    } else {
      // Show instructions for enabling permissions
      setState(() {
        _permissionsGranted = false;
      });
      _showPermissionRationale();
    }
  }

  void _refreshApp() {
    _checkPermissionsAndInitialize();
  }

  void _showPermissionRationale() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'We need location and activity permissions to track your movements and provide better services.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings(); // Direct user to app settings
            },
            child: const Text('Grant Permissions'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  double _opacity = 0.0; // Initial opacity value
  bool _showSlider = false;

  bool isDrawerOpen = false; // To track whether the slider is visible

  void _toggleSlider() {
    setState(() {
      _showSlider = !_showSlider;
    });
  }

  void turnLinesOnOff() {
    setState(() {
      linesOn = !linesOn;
    });
  }

  void showHeaderOnOff() {
    setState(() {
      showHeader = !showHeader;
    });
  }

  void clearLast() async {
    if (visitedAreas.isNotEmpty) {
      setState(() {
        LatLng last = visitedAreas.last;
        visitedAreas.remove(last);
        tileID = DateTime.now().millisecondsSinceEpoch.toString();
      });
      debugPrint(visitedAreas.toString());
      await _storageService?.updateSavedAreas(visitedAreas);
    }
  }

  void _updateMarkersBasedOnZoom() {
    if (zoom.floor() == 3) {
      setState(() {
        _markers.addAll([
          Marker(
            markerId: const MarkerId('marker2'),
            position: const LatLng(55.943495, -3.183296),
            infoWindow: const InfoWindow(title: 'Edinburgh'),
            onTap: () {
              _zoomToMarker(const LatLng(55.943495, -3.183296));
            },
          ),
        ]);
      });
    } else {
      setState(() {
        _markers.clear();
      });
    }
  }

  Future<void> _zoomToMarker(LatLng position) async {
    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Permissions Required'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Location and activity permissions are required to use this app.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _refreshApp,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      onDrawerChanged: (isOpen) => {
        setState(() {
          isDrawerOpen = isOpen;
        }),
        debugPrint(isDrawerOpen.toString())
      },
      drawer: Drawer(
        width: 150,
        backgroundColor: Colors.transparent,
        child: ListView(children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                child: FloatingActionButton(
                  onPressed: () => {Navigator.of(context).pop()},
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.cyanAccent,
                  tooltip: 'Back',
                  child: Icon(Icons.arrow_back_sharp),
                ),
              )
            ],
          ),
          Row(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: FloatingActionButton(
                onPressed: _toggleSlider,
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.cyanAccent,
                tooltip: 'Adjust Opacity',
                child:
                    Icon(_showSlider ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            if (_showSlider)
              Expanded(
                child: Slider(
                  value: _opacity,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _opacity = value;
                    });
                  },
                ),
              ),
          ]),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: FloatingActionButton(
                  onPressed: clearLast,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.cyanAccent,
                  tooltip: 'Clear Last Location',
                  child: Icon(Icons.remove_circle),
                ),
              )
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: FloatingActionButton(
                  onPressed: turnLinesOnOff,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.cyanAccent,
                  tooltip: 'Lines',
                  child:
                      Icon(linesOn ? Icons.edit_road_sharp : Icons.remove_road),
                ),
              )
            ],
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: FloatingActionButton(
                  onPressed: showHeaderOnOff,
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.cyanAccent,
                  tooltip: 'Header',
                  child: Icon(showHeader
                      ? Icons.app_shortcut
                      : Icons.app_shortcut_outlined),
                ),
              )
            ],
          ),
        ]),
      ),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialLocation,
            zoom: zoom,
          ),
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          minMaxZoomPreference: const MinMaxZoomPreference(3, 16.5),
          style: _mapStyle,
          markers: _markers,
          onCameraMove: (CameraPosition position) {
            setState(() {
              zoom = position.zoom;
            });
            _updateMarkersBasedOnZoom();
          },
          tileOverlays: {
            TileOverlay(
                tileOverlayId: TileOverlayId(tileID),
                tileProvider: CustomTileProvider(visitedAreas),
                transparency: _opacity)
          },
          onMapCreated: (controller) {
            setState(() {
              _mapController = controller;
              _mapLoaded = true;
            });
          },
          polylines: _polylines,
          mapType: MapType.normal,
        ),
        Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Builder(builder: (context) {
                    if (isDrawerOpen) {
                      return SizedBox.shrink(); // Return an empty widget
                    }
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      color: Colors.white,
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                        // Handle hamburger menu action
                      },
                    );
                  }),

                  // const Image(
                  //   image: AssetImage('assets/app-bar-8.png'),
                  //   width: 60,
                  //   height: 40,
                  // ),

                  !isDrawerOpen
                      ? Text(
                          'Explore',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        )
                      : SizedBox.shrink(),
                  // IconButton(
                  //   icon: const Icon(Icons.person_outline_rounded),
                  //   color: Colors.white,
                  //   onPressed: () {
                  //     // Handle profile action
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
        if (!_mapLoaded)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
      ]),
    );
  }
}
