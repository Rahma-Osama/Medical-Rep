class LocationParser {
  static (double lat, double lng) parse(String location) {
  final parts = location.split(',');

  if (parts.length != 2) {
  throw Exception("Invalid location format");
  }

  return (
  double.parse(parts[0].trim()),
  double.parse(parts[1].trim()),
  );
  }
}