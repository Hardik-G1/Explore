import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/visited_locations.dart';

class StorageService {
  static const String _storageKey = 'visited_locations';
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  Future<void> saveVisitedLocation(LatLng location,
      {String username = 'guest'}) async {
    final visitedLocation = VisitedLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      visitedAt: DateTime.now(),
      username: username,
    );

    List<String> locations = _prefs.getStringList(_storageKey) ?? [];
    locations.add(jsonEncode(visitedLocation.toJson()));
    await _prefs.setStringList(_storageKey, locations);
  }

  Future<void> saveMultipleLocations(List<LatLng> locations,
      {String username = 'guest'}) async {
    List<String> storedLocations = _prefs.getStringList(_storageKey) ?? [];

    for (var location in locations) {
      final visitedLocation = VisitedLocation(
        latitude: location.latitude,
        longitude: location.longitude,
        visitedAt: DateTime.now(),
        username: username,
      );
      storedLocations.add(jsonEncode(visitedLocation.toJson()));
    }

    await _prefs.setStringList(_storageKey, storedLocations);
  }

  List<VisitedLocation> getVisitedLocations() {
    final locations = _prefs.getStringList(_storageKey) ?? [];
    return locations
        .map((String locationJson) {
          try {
            final decoded = jsonDecode(locationJson);
            if (decoded is! Map<String, dynamic>) {
              throw FormatException('Invalid JSON format: $decoded');
            }
            return VisitedLocation.fromJson(decoded);
          } catch (e) {
            return null; // Return null for invalid entries
          }
        })
        .whereType<VisitedLocation>() // Filter out nulls
        .toList();
  }

  Set<LatLng> getVisitedLatLng() {
    return getVisitedLocations()
        .map((location) => LatLng(location.latitude, location.longitude))
        .toSet();
  }

  Future<void> clearVisitedLocations() async {
    await _prefs.remove(_storageKey);
  }

  Future<void> removeLocation() async {
    List<VisitedLocation> locations = getVisitedLocations();
    if (locations.isNotEmpty) {
      locations.removeLast();
    }

    List<String> encodedLocations =
        locations.map((location) => jsonEncode(location.toJson())).toList();

    await _prefs.setStringList(_storageKey, encodedLocations);
  }

  Future<void> updateSavedAreas(Set<LatLng> visitedAreas) async {
    List<String> encodedLocations = visitedAreas
        .map((location) => jsonEncode({
              'latitude': location.latitude,
              'longitude': location.longitude,
            }))
        .toList();

    await _prefs.setStringList(_storageKey, encodedLocations);
  }
}
