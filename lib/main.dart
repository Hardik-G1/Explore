import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hello_world/screens/home_page.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import '../services/background_location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load();
    print('ENV loaded: ${dotenv.env['GOOGLE_MAPS_API_KEY']}'); // Debug print
  } catch (e) {
    print('Failed to load .env file: $e');
  }
  
  bg.BackgroundGeolocation.registerHeadlessTask(LocationService.headlessTask);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explore',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(26, 1, 1, 1),
      ),
      home: const HomePage(),
    );
  }
}

// import 'dart:ui' as ui;
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
// import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
// import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Explore',
//       theme: ThemeData(
//         primaryColor: const ui.Color.fromRGBO(26, 1, 1, 1),
//       ),
//       home: const MapScreen(),
//     );
//   }
// }

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<StatefulWidget> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   final List<LatLng> visitedAreas = [
//     LatLng(37.7749, -122.4194),
//     LatLng(37.7849, -122.4094),
//     LatLng(55.943495, -3.183296),
//     LatLng(55.943794, -3.183463),
//     LatLng(55.944511, -3.183785),
//     LatLng(55.945296, -3.184353),
//   ];
//   LatLng intialLocation = LatLng(55.943495, -3.183296);
//   double zoom = 12;
//   String? _mapStyle;
//   bool _mapLoaded = false;
//   String tileID = "CustomMask";
//   bool hideMap = true;
//   late GoogleMapController _mapController;
//   final Location _location = Location();
//   bool _permissionGranted = false;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   final List<Polyline> _polylinesList = [
//     Polyline(
//       polylineId: PolylineId('route1'),
//       points: [
//         LatLng(55.943495, -3.183296),
//         LatLng(55.943794, -3.183463),
//         LatLng(55.944511, -3.183785),
//         LatLng(55.945296, -3.184353),
//       ],
//       color: Colors.blue,
//       width: 6,
//     ),
//     Polyline(
//       polylineId: PolylineId('route2'),
//       points: [
//         LatLng(34.0522, -118.2437), // Los Angeles
//         LatLng(34.0622, -118.2537), // Nearby point
//       ],
//       color: Colors.green,
//       width: 6,
//     ),
//     Polyline(
//       polylineId: PolylineId('route3'),
//       points: [
//         LatLng(40.7128, -74.0060), // New York City
//         LatLng(40.7228, -74.0160), // Nearby point
//       ],
//       color: Colors.red,
//       width: 6,
//     ),
//   ];

//   void _initializeMapRenderer() {
//     final GoogleMapsFlutterPlatform mapsImplementation =
//         GoogleMapsFlutterPlatform.instance;
//     if (mapsImplementation is GoogleMapsFlutterAndroid) {
//       mapsImplementation.useAndroidViewSurface = true;
//     }
//   }

//   Future<void> _initializeLocation() async {
//     // Check and request location permissions
//     bool serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) return;
//     }

//     PermissionStatus permissionGranted = await _location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) return;
//     }

//     // Get initial location
//     final locationData = await _location.getLocation();
//     setState(() {
//       intialLocation = LatLng(locationData.latitude!, locationData.longitude!);
//       _permissionGranted = true;
//     });

//     // Listen for location updates
//     _location.onLocationChanged.listen((LocationData locationData) {
//       setState(() {
//         intialLocation =
//             LatLng(locationData.latitude!, locationData.longitude!);
//       });
//       _updateLocation(locationData);

//       // Move the camera to the updated location
//     });
//   }

//   void _updateLocation(LocationData locationData) {
//     if (locationData.latitude != null && locationData.longitude != null) {
//       final newLocation =
//           LatLng(locationData.latitude!, locationData.longitude!);
//       setState(() {
//         intialLocation = newLocation;

//         // Add live location to visitedAreas if it hasn't been recorded recently
//         if (visitedAreas.isEmpty ||
//             !_isLocationClose(visitedAreas.last, newLocation)) {
//           visitedAreas.add(newLocation);
//         }
//       });

//       // Optionally animate camera to new location
//       _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
//     }
//   }

//   bool _isLocationClose(LatLng a, LatLng b, {double thresholdMeters = 10.0}) {
//     const double earthRadiusMeters = 6371000;
//     final dLat = (b.latitude - a.latitude) * (math.pi / 180);
//     final dLng = (b.longitude - a.longitude) * (math.pi / 180);
//     final lat1 = a.latitude * (math.pi / 180);
//     final lat2 = b.latitude * (math.pi / 180);

//     final aCalc = math.sin(dLat / 2) * math.sin(dLat / 2) +
//         math.sin(dLng / 2) *
//             math.sin(dLng / 2) *
//             math.cos(lat1) *
//             math.cos(lat2);
//     final c = 2 * math.atan2(math.sqrt(aCalc), math.sqrt(1 - aCalc));
//     final distance = earthRadiusMeters * c;

//     return distance <= thresholdMeters;
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Load the map style from assets
//     rootBundle.loadString('assets/styles.json').then((style) {
//       setState(() {
//         _mapStyle = style;
//       });
//     });
//     _initializePolylines();
//     _initializeLocation();
//     _initializeMapRenderer();
//   }

//   void unhide() {
//     setState(() {
//       hideMap = !hideMap;
//     });
//   }

//   void _updateMarkersBasedOnZoom() {
//     // Check the current zoom level
//     if (zoom.floor() == 3) {
//       // Add markers for zoom level 3
//       setState(() {
//         _markers.addAll([
//           Marker(
//             markerId: MarkerId('marker1'),
//             position: LatLng(37.7749, -122.4194), // Example location
//             infoWindow: InfoWindow(title: 'Marker 1 at Zoom 3'),
//             onTap: () {
//               _zoomToMarker(LatLng(37.7749, -122.4194));
//             },
//           ),
//           Marker(
//             markerId: MarkerId('marker2'),
//             position: LatLng(55.943495, -3.183296), // Example location
//             infoWindow: InfoWindow(title: 'Marker 2 at Zoom 3'),
//             onTap: () {
//               _zoomToMarker(LatLng(55.943495, -3.183296));
//             },
//           ),
//         ]);
//       });
//     } else {
//       // Remove markers for other zoom levels
//       setState(() {
//         _markers.clear();
//       });
//     }
//   }

//   void _initializePolylines() {
//     // Add all the polylines to the set
//     _polylines.addAll(_polylinesList);
//   }

//   Future<void> _zoomToMarker(LatLng position) async {
//     // Animate the camera to zoom and center on the marker
//     await _mapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//             target: position, zoom: 15), // Adjust zoom level as needed
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Explore"),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: intialLocation,
//               zoom: zoom,
//             ),
//             myLocationEnabled: _permissionGranted, // Show the blue dot
//             myLocationButtonEnabled: true, // Add "my location" button
//             minMaxZoomPreference: MinMaxZoomPreference(3, 16.5),
//             style: _mapStyle,
//             markers: _markers,
//             onCameraMove: (CameraPosition position) {
//               setState(() {
//                 zoom = position.zoom;
//               });
//               _updateMarkersBasedOnZoom();
//             },
//             tileOverlays: {
//               TileOverlay(
//                   tileOverlayId: TileOverlayId(tileID),
//                   tileProvider: CustomTileProvider(visitedAreas),
//                   zIndex: 1,
//                   visible: hideMap)
//             },
//             onMapCreated: (controller) {
//               setState(() {
//                 _mapLoaded = true;
//               });
//               _mapController = controller;
//             },
//             polylines: _polylines,
//             mapType: MapType.normal,
//           ),
//           TextButton(onPressed: unhide, child: Text("Unhide")),
//           if (!_mapLoaded)
//             Positioned.fill(
//               child: Container(
//                 color: Colors.black,
//                 child: const Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class CustomTileProvider extends TileProvider {
//   final List<LatLng> visitedAreas;
//   CustomTileProvider(this.visitedAreas);

//   @override
//   Future<Tile> getTile(int x, int y, int? zoom) async {
//     final bounds = _getTileBounds(x, y, zoom ?? 0);
//     debugPrint(bounds.northeast.toString() + bounds.southwest.toString());
//     final image = await _generateTileImage(bounds, zoom ?? 0);
//     return Tile(256, 256, image);
//   }

//   LatLngBounds _getTileBounds(int x, int y, int zoom) {
//     final n = math.pow(2.0, zoom); // Number of tiles at this zoom level
//     final s = 256 / n;
//     final sw = {x: x * s, y: y * s + s};
//     final ne = {x: x * s + s, y: y * s};
//     // Calculate the longitude of the southwest and northeast corners
//     final lon1 = (sw[x]! - 128) / (256 / 360);
//     final lon2 = (ne[x]! - 128) / (256 / 360);

//     // Calculate the latitude of the southwest and northeast corners using the Mercator projection
//     final lat1 =
//         (2 * math.atan(math.exp((sw[y]! - 128) / -(256 / (2 * math.pi)))) -
//                 math.pi / 2) /
//             (math.pi / 180);
//     final lat2 =
//         (2 * math.atan(math.exp((ne[y]! - 128) / -(256 / (2 * math.pi)))) -
//                 math.pi / 2) /
//             (math.pi / 180);

//     return LatLngBounds(
//       southwest: LatLng(lat1, lon1), // Southwest corner of the tile
//       northeast: LatLng(lat2, lon2), // Northeast corner of the tile
//     );
//   }

//   Future<Uint8List> _generateTileImage(LatLngBounds bounds, int zoom) async {
//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

//     // Fill the tile with black (Layer 1)
//     final paint = Paint()..color = Colors.black;
//     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

//     // Adjust radii based on zoom level
//     double innerRadius = _calculateRadius(zoom); // Inner clear hole
//     double outerRadius =
//         innerRadius + (innerRadius * 3); // Outer semi-transparent ring

//     for (final point in visitedAreas) {
//       // Calculate circle bounds
//       final offset = _latLngToTileOffset(point, bounds);
//       final circleBounds = Rect.fromCircle(center: offset, radius: outerRadius);

//       // Check if the circle intersects the current tile
//       final tileRect = Rect.fromLTWH(0, 0, 256, 256);
//       if (circleBounds.overlaps(tileRect)) {
//         // Step 1: Clear the inner circle
//         paint.blendMode =
//             BlendMode.clear; // Clear pixels to reveal Layer 0 (the map)
//         paint.color = Colors.transparent; // Ensure it's fully transparent
//         canvas.drawCircle(offset, innerRadius, paint);
//         paint.blendMode =
//             BlendMode.dstOut; // Subtract alpha to make it slightly transparent
//         paint.color = const ui.Color.fromRGBO(0, 0, 0, 0.7);
//         paint.style = PaintingStyle.stroke; // Stroke only (donut effect)
//         paint.strokeWidth = outerRadius - innerRadius; // Thickness of the ring
//         canvas.drawCircle(offset, (innerRadius + outerRadius) / 2, paint);
//         // Step 2: Add semi-transparent ring
//         // paint.blendMode =
//         //     BlendMode.dstOut; // Subtract alpha to make it slightly transparent
//         // paint.color =
//         //     Colors.black.withOpacity(0.5); // Semi-transparent for the ring
//         // paint.style = PaintingStyle.stroke; // Stroke only (donut effect)
//         // paint.strokeWidth = outerRadius - innerRadius; // Thickness of the ring
//         // canvas.drawCircle(offset, (innerRadius + outerRadius) / 2, paint);
//       }
//     }

//     // Finalize the tile image
//     final image = await recorder.endRecording().toImage(256, 256);
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     return byteData!.buffer.asUint8List();
//   }
//   // Future<Uint8List> _generateTileImage(LatLngBounds bounds, int zoom) async {
//   //   final recorder = ui.PictureRecorder();
//   //   final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

//   //   // Fill the tile with black
//   //   final paint = Paint()..color = Colors.black;
//   //   canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

//   //   // Adjust radius based on zoom level
//   //   //double radius = _calculateRadius(zoom);
//   //   double innerRadius = _calculateRadius(zoom); // Transparent inner radius
//   //   double outerRadius = innerRadius * 5;
//   //   // Draw transparent circles for visited areas
//   //   paint.blendMode = BlendMode.clear;
//   //   for (final point in visitedAreas) {
//   //     if (_isPointWithinBounds(point, bounds)) {
//   //       final offset = _latLngToTileOffset(point, bounds);
//   //       canvas.drawCircle(offset, innerRadius, paint);
//   //       paint.blendMode =
//   //           BlendMode.dstOut; // Subtract alpha to make it slightly transparent
//   //       paint.color = const ui.Color.fromRGBO(0, 0, 0, 0.7);
//   //       paint.style = PaintingStyle.stroke; // Stroke only (donut effect)
//   //       paint.strokeWidth = outerRadius - innerRadius; // Thickness of the ring
//   //       canvas.drawCircle(offset, (innerRadius + outerRadius) / 2, paint);
//   //     }
//   //   }

//   //   final image = await recorder.endRecording().toImage(256, 256);
//   //   final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//   //   return byteData!.buffer.asUint8List();
//   // }

//   double _calculateRadius(int zoom) {
//     // Example: radius grows with zoom
//     const double baseRadius = 20.0; // Minimum radius
//     return baseRadius * (zoom / 20.0); // Adjust scaling factor as needed
//   }

//   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
//     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
//         (bounds.northeast.longitude - bounds.southwest.longitude);
//     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
//         (bounds.northeast.latitude - bounds.southwest.latitude);
//     return Offset(xRatio * 256, (1 - yRatio) * 256);
//   }

//   // bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
//   //   return point.latitude >= bounds.southwest.latitude &&
//   //       point.latitude <= bounds.northeast.latitude &&
//   //       point.longitude >= bounds.southwest.longitude &&
//   //       point.longitude <= bounds.northeast.longitude;
//   // }
// }

// class LatLngBounds {
//   final LatLng southwest;
//   final LatLng northeast;

//   LatLngBounds({required this.southwest, required this.northeast});
// }

// // import 'dart:async';
// // import 'dart:math' as math;

// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   State<StatefulWidget> createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //     LatLng(55.943495, -3.183296),
// //     LatLng(55.943794, -3.183463),
// //     LatLng(55.944511, -3.183785),
// //     LatLng(55.945296, -3.184353),
// //   ];

// //   String? _mapStyle;
// //   bool _mapLoaded = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(55.943495, -3.183296),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Adjust radius based on zoom level
// //     double innerRadius = _calculateRadius(zoom); // Transparent inner radius
// //     double outerRadius = innerRadius * 5;
// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, innerRadius, paint);
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }

// // import 'dart:async';
// // import 'dart:math' as math;
// // import 'dart:ui' as ui;

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart'; // For rootBundle
// // import 'package:google_maps_flutter/google_maps_flutter.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Dynamic Map Masking',
// //       theme: ThemeData(
// //         primarySwatch: Colors.blue,
// //       ),
// //       home: const MapScreen(),
// //     );
// //   }
// // }

// // class MapScreen extends StatefulWidget {
// //   const MapScreen({super.key});

// //   @override
// //   _MapScreenState createState() => _MapScreenState();
// // }

// // class _MapScreenState extends State<MapScreen> {
// //   final List<LatLng> visitedAreas = [
// //     LatLng(37.7749, -122.4194), // San Francisco
// //     LatLng(37.7849, -122.4094), // Nearby point
// //   ];

// //   String? _mapStyle;

// //   @override
// //   void initState() {
// //     super.initState();
// //     // Load the map style from assets
// //     rootBundle.loadString('assets/styles.json').then((style) {
// //       setState(() {
// //         _mapStyle = style;
// //       });
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Dynamic Map Masking'),
// //       ),
// //       body: Stack(
// //         children: [
// //           GoogleMap(
// //             initialCameraPosition: const CameraPosition(
// //               target: LatLng(37.7749, -122.4194),
// //               zoom: 12,
// //             ),
// //             style: _mapStyle,
// //             tileOverlays: {
// //               TileOverlay(
// //                 tileOverlayId: const TileOverlayId('customMask'),
// //                 tileProvider: CustomTileProvider(visitedAreas),
// //               ),
// //             },
// //             onMapCreated: (GoogleMapController controller) {
// //               setState(() {
// //                 _mapLoaded = true;
// //               });
// //             },
// //             onTap: (position) {
// //               // Mark new area as visited when tapped
// //               setState(() {
// //                 visitedAreas.add(position);
// //               });
// //             },
// //           ),
// //           if (!_mapLoaded)
// //             Positioned.fill(
// //               child: Container(
// //                 color: Colors.black,
// //                 child: const Center(
// //                   child: CircularProgressIndicator(color: Colors.white),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class CustomTileProvider extends TileProvider {
// //   final List<LatLng> visitedAreas;

// //   CustomTileProvider(this.visitedAreas);

// //   @override
// //   Future<Tile> getTile(int x, int y, int? zoom) async {
// //     final bounds = _getTileBounds(x, y, zoom ?? 0);
// //     final image = await _generateTileImage(bounds);
// //     return Tile(256, 256, image);
// //   }

// //   LatLngBounds _getTileBounds(int x, int y, int zoom) {
// //     final n = math.pow(2.0, zoom);
// //     final lon1 = x / n * 360.0 - 180.0;
// //     final lon2 = (x + 1) / n * 360.0 - 180.0;
// //     final lat1 =
// //         math.atan(math.sin(math.pi * (1 - 2 * y / n))) * 180.0 / math.pi;
// //     final lat2 =
// //         math.atan(math.sin(math.pi * (1 - 2 * (y + 1) / n))) * 180.0 / math.pi;
// //     return LatLngBounds(
// //       southwest: LatLng(lat2, lon1),
// //       northeast: LatLng(lat1, lon2),
// //     );
// //   }

// //   Future<Uint8List> _generateTileImage(LatLngBounds bounds) async {
// //     final recorder = ui.PictureRecorder();
// //     final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

// //     // Fill the tile with black
// //     final paint = Paint()..color = Colors.black;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     // Draw transparent circles for visited areas
// //     paint.color = Colors.transparent;
// //     paint.blendMode = BlendMode.clear;
// //     for (final point in visitedAreas) {
// //       if (_isPointWithinBounds(point, bounds)) {
// //         final offset = _latLngToTileOffset(point, bounds);
// //         canvas.drawCircle(offset, 10.0, paint); // Adjust radius as needed
// //       }
// //     }

// //     // Draw a black rectangle over the tile to hide place names
// //     paint.color = Colors.black;
// //     paint.blendMode = BlendMode.srcOver;
// //     canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

// //     final image = await recorder.endRecording().toImage(256, 256);
// //     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
// //     return byteData!.buffer.asUint8List();
// //   }

// //   Offset _latLngToTileOffset(LatLng latLng, LatLngBounds bounds) {
// //     final xRatio = (latLng.longitude - bounds.southwest.longitude) /
// //         (bounds.northeast.longitude - bounds.southwest.longitude);
// //     final yRatio = (latLng.latitude - bounds.southwest.latitude) /
// //         (bounds.northeast.latitude - bounds.southwest.latitude);
// //     return Offset(xRatio * 256, (1 - yRatio) * 256);
// //   }

// //   bool _isPointWithinBounds(LatLng point, LatLngBounds bounds) {
// //     return point.latitude >= bounds.southwest.latitude &&
// //         point.latitude <= bounds.northeast.latitude &&
// //         point.longitude >= bounds.southwest.longitude &&
// //         point.longitude <= bounds.northeast.longitude;
// //   }
// // }

// // class LatLngBounds {
// //   final LatLng southwest;
// //   final LatLng northeast;

// //   LatLngBounds({required this.southwest, required this.northeast});
// // }
