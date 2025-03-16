class VisitedLocation {
  final double latitude;
  final double longitude;
  final DateTime visitedAt;
  final String username;

  VisitedLocation({
    required this.latitude,
    required this.longitude,
    required this.visitedAt,
    this.username = 'guest',
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'visitedAt': visitedAt.toIso8601String(),
      'username': username,
    };
  }

  factory VisitedLocation.fromJson(Map<String, dynamic> json) {
    return VisitedLocation(
      latitude: json['latitude'],
      longitude: json['longitude'],
      visitedAt: DateTime.parse(json['visitedAt']),
      username: json['username'] ?? 'guest',
    );
  }
}
