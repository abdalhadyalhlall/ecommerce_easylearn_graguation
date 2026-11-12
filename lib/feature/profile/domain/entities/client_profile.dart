class ClientProfile {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? pictureUrl;

  const ClientProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.pictureUrl,
  });

  factory ClientProfile.fromJson(Map<String, dynamic> json) {
    return ClientProfile(
      id: _asInt(json['id']),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      latitude: _asNullableDouble(json['latitude']),
      longitude: _asNullableDouble(json['longitude']),
      pictureUrl: json['picture_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'picture_url': pictureUrl,
  };
}

int _asInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;

double? _asNullableDouble(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());
