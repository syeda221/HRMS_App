class OfficeQrModel {
  final int officeId;
  final String name;
  final String qrSecretKey;
  final String qrPayload;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final bool isActive;
  final String lastRegenerated;

  OfficeQrModel({
    required this.officeId,
    required this.name,
    required this.qrSecretKey,
    required this.qrPayload,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.lastRegenerated,
  });

  factory OfficeQrModel.fromJson(Map<String, dynamic> json) {
    return OfficeQrModel(
      officeId: json['office_id'] ?? 1,
      name: json['name'] ?? 'HQ Main Office',
      qrSecretKey: json['qr_secret_key'] ?? '',
      qrPayload: json['qr_payload'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 24.8607,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 67.0011,
      radiusMeters: json['radius_meters'] ?? 150,
      isActive: json['is_active'] ?? true,
      lastRegenerated: json['last_regenerated'] ?? 'Just now',
    );
  }
}
