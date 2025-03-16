import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/lat_lng_bounds.dart';
import '../utils/map_utils.dart';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class CustomTileProvider extends TileProvider {
  final Set<LatLng> visitedAreas;
  CustomTileProvider(this.visitedAreas);
  // CustomTileProvider(this.visitedAreas);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final bounds = _getTileBounds(x, y, zoom ?? 0);
    final image = await _generateTileImage(bounds, zoom ?? 0);
    return Tile(256, 256, image);
  }

  LatLongBounds _getTileBounds(int x, int y, int zoom) {
    final n = math.pow(2.0, zoom);
    final s = 256 / n;
    final sw = {x: x * s, y: y * s + s};
    final ne = {x: x * s + s, y: y * s};

    final lon1 = (sw[x]! - 128) / (256 / 360);
    final lon2 = (ne[x]! - 128) / (256 / 360);
    final lat1 =
        (2 * math.atan(math.exp((sw[y]! - 128) / -(256 / (2 * math.pi)))) -
                math.pi / 2) /
            (math.pi / 180);
    final lat2 =
        (2 * math.atan(math.exp((ne[y]! - 128) / -(256 / (2 * math.pi)))) -
                math.pi / 2) /
            (math.pi / 180);

    return LatLongBounds(
      southwest: LatLng(lat1, lon1),
      northeast: LatLng(lat2, lon2),
    );
  }

  Future<Uint8List> _generateTileImage(LatLongBounds bounds, int zoom) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, 256, 256));

    // Fill the tile with black (Layer 1)
    final paint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, 256, 256), paint);

    // Adjust radii based on zoom level
    double innerRadius = MapUtils.calculateRadius(zoom); // Inner clear hole
    double outerRadius =
        innerRadius + (innerRadius * 2); // Outer semi-transparent ring

    for (final point in visitedAreas) {
      // Calculate circle bounds
      final offset = _latLngToTileOffset(point, bounds);
      final circleBounds = Rect.fromCircle(center: offset, radius: outerRadius);

      // Check if the circle intersects the current tile
      final tileRect = Rect.fromLTWH(0, 0, 256, 256);
      if (circleBounds.overlaps(tileRect)) {
        // Step 1: Clear the inner circle
        paint.blendMode =
            BlendMode.clear; // Clear pixels to reveal Layer 0 (the map)
        paint.color = Colors.transparent; // Ensure it's fully transparent
        canvas.drawCircle(offset, innerRadius, paint);
        paint.blendMode =
            BlendMode.dstOut; // Subtract alpha to make it slightly transparent
        paint.color = const ui.Color.fromRGBO(0, 0, 0, 0.7);
        paint.style = PaintingStyle.stroke; // Stroke only (donut effect)
        paint.strokeWidth = outerRadius - innerRadius; // Thickness of the ring
        canvas.drawCircle(offset, (innerRadius + outerRadius) / 2, paint);
      }
    }

    // Finalize the tile image
    final image = await recorder.endRecording().toImage(256, 256);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Offset _latLngToTileOffset(LatLng latLng, LatLongBounds bounds) {
    final xRatio = (latLng.longitude - bounds.southwest.longitude) /
        (bounds.northeast.longitude - bounds.southwest.longitude);
    final yRatio = (latLng.latitude - bounds.southwest.latitude) /
        (bounds.northeast.latitude - bounds.southwest.latitude);
    return Offset(xRatio * 256, (1 - yRatio) * 256);
  }

  // bool _isPointWithinBounds(LatLng point, LatLongBounds bounds) {
  //   return point.latitude >= bounds.southwest.latitude &&
  //       point.latitude <= bounds.northeast.latitude &&
  //       point.longitude >= bounds.southwest.longitude &&
  //       point.longitude <= bounds.northeast.longitude;
  // }
}
