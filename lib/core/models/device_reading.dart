class DeviceReading {
  const DeviceReading({
    required this.device,
    required this.sampleId,
    required this.feedType,
    required this.moisture,
    required this.protein,
    required this.fiber,
    required this.fat,
    required this.ash,
    required this.ph,
    required this.temperature,
    required this.status,
    required this.receivedAt,
  });

  final String device;
  final String sampleId;
  final String feedType;

  final double moisture;
  final double protein;
  final double fiber;
  final double fat;
  final double ash;
  final double ph;
  final double temperature;

  final String status;
  final DateTime receivedAt;

  bool get isComplete => status.toLowerCase() == 'complete';

  factory DeviceReading.fromJson(Map<String, dynamic> json) {
    return DeviceReading(
      device: _readString(json, 'device', fallback: 'PARAKH-01'),
      sampleId: _readString(json, 'sampleId', fallback: 'Unknown'),
      feedType: _readString(json, 'feedType', fallback: 'Unknown feed'),
      moisture: _readDouble(json, 'moisture'),
      protein: _readDouble(json, 'protein'),
      fiber: _readDouble(json, 'fiber'),
      fat: _readDouble(json, 'fat'),
      ash: _readDouble(json, 'ash'),
      ph: _readDouble(json, 'ph'),
      temperature: _readDouble(json, 'temperature'),
      status: _readString(json, 'status', fallback: 'complete'),
      receivedAt: _readDateTime(json, 'receivedAt'),
    );
  }

  factory DeviceReading.demo({
    String sampleId = 'S001',
    String feedType = 'Maize Silage',
  }) {
    return DeviceReading(
      device: 'PARAKH-01',
      sampleId: sampleId,
      feedType: feedType,
      moisture: 12.4,
      protein: 18.7,
      fiber: 24.2,
      fat: 3.8,
      ash: 6.1,
      ph: 6.4,
      temperature: 27.5,
      status: 'complete',
      receivedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device': device,
      'sampleId': sampleId,
      'feedType': feedType,
      'moisture': moisture,
      'protein': protein,
      'fiber': fiber,
      'fat': fat,
      'ash': ash,
      'ph': ph,
      'temperature': temperature,
      'status': status,
      'receivedAt': receivedAt.toIso8601String(),
    };
  }

  static String _readString(
    Map<String, dynamic> json,
    String key, {
    required String fallback,
  }) {
    final value = json[key];

    if (value == null) {
      return fallback;
    }

    final convertedValue = value.toString().trim();

    return convertedValue.isEmpty ? fallback : convertedValue;
  }

  static double _readDouble(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim()) ?? 0;
    }

    return 0;
  }

  static DateTime _readDateTime(Map<String, dynamic> json, String key) {
    final value = json[key];

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }
}
