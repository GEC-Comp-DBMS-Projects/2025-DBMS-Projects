class ParkingSpot {
  final String id;
  final String name;
  final String type; // '2-wheeler' or '4-wheeler'
  final double x;
  final double y;
  final bool isOccupied;
  final String? occupiedBy; // User ID who parked here
  final DateTime? occupiedAt;
  final String? vehicleId; // ID of the parked vehicle
  final String? vehicleName; // Name of the parked vehicle
  final String? vehicleLicensePlate; // License plate of the parked vehicle
  final String? vehicleType; // Type of the parked vehicle (car, motorcycle, etc.)
  final bool isGuestVehicle; // Whether it's a guest vehicle
  final DateTime createdAt;
  final DateTime updatedAt;

  ParkingSpot({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    required this.isOccupied,
    this.occupiedBy,
    this.occupiedAt,
    this.vehicleId,
    this.vehicleName,
    this.vehicleLicensePlate,
    this.vehicleType,
    this.isGuestVehicle = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert ParkingSpot to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'x': x,
      'y': y,
      'isOccupied': isOccupied,
      'occupiedBy': occupiedBy,
      'occupiedAt': occupiedAt?.toIso8601String(),
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehicleLicensePlate': vehicleLicensePlate,
      'vehicleType': vehicleType,
      'isGuestVehicle': isGuestVehicle,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create ParkingSpot from Map (from Firestore)
  factory ParkingSpot.fromMap(Map<String, dynamic> map) {
    return ParkingSpot(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      x: (map['x'] ?? 0.0).toDouble(),
      y: (map['y'] ?? 0.0).toDouble(),
      isOccupied: map['isOccupied'] ?? false,
      occupiedBy: map['occupiedBy'],
      occupiedAt: map['occupiedAt'] != null ? DateTime.parse(map['occupiedAt']) : null,
      vehicleId: map['vehicleId'],
      vehicleName: map['vehicleName'],
      vehicleLicensePlate: map['vehicleLicensePlate'],
      vehicleType: map['vehicleType'],
      isGuestVehicle: map['isGuestVehicle'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a copy of ParkingSpot with updated fields
  ParkingSpot copyWith({
    String? id,
    String? name,
    String? type,
    double? x,
    double? y,
    bool? isOccupied,
    String? occupiedBy,
    DateTime? occupiedAt,
    String? vehicleId,
    String? vehicleName,
    String? vehicleLicensePlate,
    String? vehicleType,
    bool? isGuestVehicle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParkingSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      isOccupied: isOccupied ?? this.isOccupied,
      occupiedBy: occupiedBy ?? this.occupiedBy,
      occupiedAt: occupiedAt ?? this.occupiedAt,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleLicensePlate: vehicleLicensePlate ?? this.vehicleLicensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      isGuestVehicle: isGuestVehicle ?? this.isGuestVehicle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ParkingSpot(id: $id, name: $name, type: $type, isOccupied: $isOccupied)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkingSpot && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
