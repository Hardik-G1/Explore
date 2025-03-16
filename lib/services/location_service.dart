// import 'package:location/location.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/material.dart';

// class LocationService {
//   final Location _location = Location();
//   final Function(LocationData) onLocationChanged;

//   LocationService({required this.onLocationChanged});

//   Future<bool> initialize() async {
//     bool serviceEnabled = await _location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await _location.requestService();
//       if (!serviceEnabled) return false;
//     }

//     PermissionStatus permissionGranted = await _location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await _location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) return false;
//     }

//     _location.onLocationChanged.listen(onLocationChanged);
//     return true;
//   }

//   Future<LocationData?> getCurrentLocation() async {
//     try {
//       return await _location.getLocation();
//     } catch (e) {
//       debugPrint('Error getting location: $e');
//       return null;
//     }
//   }
// }
// //   // Future<void> _initializeLocation() async {
// //   //   // Check and request location permissions
// //   //   bool serviceEnabled = await _location.serviceEnabled();
// //   //   if (!serviceEnabled) {
// //   //     serviceEnabled = await _location.requestService();
// //   //     if (!serviceEnabled) return;
// //   //   }

// //   //   PermissionStatus permissionGranted = await _location.hasPermission();
// //   //   if (permissionGranted == PermissionStatus.denied) {
// //   //     permissionGranted = await _location.requestPermission();
// //   //     if (permissionGranted != PermissionStatus.granted) return;
// //   //   }

// //   //   // Get initial location
// //   //   final locationData = await _location.getLocation();
// //   //   setState(() {
// //   //     intialLocation = LatLng(locationData.latitude!, locationData.longitude!);
// //   //     _permissionGranted = true;
// //   //   });

// //   //   // Listen for location updates
// //   //   _location.onLocationChanged.listen((LocationData locationData) {
// //   //     setState(() {
// //   //       intialLocation =
// //   //           LatLng(locationData.latitude!, locationData.longitude!);
// //   //     });
// //   //     _updateLocation(locationData);

// //   //     // Move the camera to the updated location
// //   //   });
// //   // }
