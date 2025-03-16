import 'package:flutter/material.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:hello_world/services/storage_service.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Function(bg.Location)? globalOnLocationChanged;

  final Function(bg.Location) onLocationChanged;

  LocationService({required this.onLocationChanged}) {
    // Assign to the static global reference
    globalOnLocationChanged = onLocationChanged;
  }

  Future<void> initialize() async {
    try {
      // Request background location permission if not already granted
      if (!await Permission.locationAlways.isGranted) {
        final status = await Permission.locationAlways.request();
        if (!status.isGranted) {
          debugPrint('Background location permission denied');
          return;
        }
      }
      // Configure the plugin
      bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        stopOnStationary: false,
        isMoving: true,
        disableStopDetection: true,
        stopTimeout: 0, // Prevent stopping after inactivity
        disableMotionActivityUpdates: true, // Avoid motion activity updates
        debug: false, // Set to false in production
        logLevel: bg.Config.LOG_LEVEL_VERBOSE,
        notificationTitle: "Your App is Tracking Location",
        notificationText: "Location tracking is active",
        backgroundPermissionRationale: bg.PermissionRationale(
          title: "Allow Location Access",
          message:
              "This app needs access to your location to track your movements and provide location-based services.",
          positiveAction: "Allow",
          negativeAction: "Cancel",
        ),
      )).then((bg.State state) {
        if (!state.enabled) {
          bg.BackgroundGeolocation
              .start(); // Start tracking if not already started
        }
      });

      // Listen for location updates
      bg.BackgroundGeolocation.onLocation((bg.Location location) {
        onLocationChanged(location);
      }, (bg.LocationError error) {
        debugPrint('Location Error: ${error.code} - ${error.message}');
      });
    } catch (e) {
      debugPrint('Error initializing location service: $e');
    }
  }

  Future<bg.Location?> getCurrentLocation() async {
    try {
      return await bg.BackgroundGeolocation.getCurrentPosition(
        samples: 1,
        timeout: 60,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  void stopTracking() {
    bg.BackgroundGeolocation.stop();
  }

  static headlessTask(bg.HeadlessEvent event) async {
    debugPrint('[HeadlessTask] - ${event.name}');
    if (event.name == bg.Event.LOCATION) {
      bg.Location location = event.event;
      StorageService? storageService;
      final newLocation =
          LatLng(location.coords.latitude, location.coords.longitude);
      storageService = await StorageService.initialize();
      storageService.saveVisitedLocation(newLocation);
    } else if (event.name == bg.Event.TERMINATE) {
      debugPrint('[HeadlessTask] App terminated');
      // Handle app termination-related tasks here.
    } else {
      debugPrint('[HeadlessTask] Unhandled event: ${event.name}');
    }
  }
}
