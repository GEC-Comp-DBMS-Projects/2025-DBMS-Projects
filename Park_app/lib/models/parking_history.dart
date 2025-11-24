class ParkingHistory {
  final String id;
  final String userId;
  final String spotId;
  final String spotName;
  final String spotType;
  final DateTime parkedAt;
  final DateTime unparkedAt;
  final Duration duration;
  final String? vehicleId;
  final String? vehicleName;
  final String? vehicleLicensePlate;
  final String? vehicleType;
  final bool isGuestVehicle;
  final DateTime createdAt;

  ParkingHistory({
    required this.id,
    required this.userId,
    required this.spotId,
    required this.spotName,
    required this.spotType,
    required this.parkedAt,
    required this.unparkedAt,
    required this.duration,
    this.vehicleId,
    this.vehicleName,
    this.vehicleLicensePlate,
    this.vehicleType,
    this.isGuestVehicle = false,
    required this.createdAt,
  });

  // Convert ParkingHistory to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'spotId': spotId,
      'spotName': spotName,
      'spotType': spotType,
      'parkedAt': parkedAt.toIso8601String(),
      'unparkedAt': unparkedAt.toIso8601String(),
      'duration': duration.inMinutes, // Store duration in minutes
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'vehicleLicensePlate': vehicleLicensePlate,
      'vehicleType': vehicleType,
      'isGuestVehicle': isGuestVehicle,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create ParkingHistory from Map (from Firestore)
  factory ParkingHistory.fromMap(Map<String, dynamic> map) {
    return ParkingHistory(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      spotId: map['spotId'] ?? '',
      spotName: map['spotName'] ?? '',
      spotType: map['spotType'] ?? '',
      parkedAt: DateTime.parse(map['parkedAt'] ?? DateTime.now().toIso8601String()),
      unparkedAt: DateTime.parse(map['unparkedAt'] ?? DateTime.now().toIso8601String()),
      duration: Duration(minutes: map['duration'] ?? 0),
      vehicleId: map['vehicleId'],
      vehicleName: map['vehicleName'],
      vehicleLicensePlate: map['vehicleLicensePlate'],
      vehicleType: map['vehicleType'],
      isGuestVehicle: map['isGuestVehicle'] ?? false,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a copy of ParkingHistory with updated fields
  ParkingHistory copyWith({
    String? id,
    String? userId,
    String? spotId,
    String? spotName,
    String? spotType,
    DateTime? parkedAt,
    DateTime? unparkedAt,
    Duration? duration,
    String? vehicleId,
    String? vehicleName,
    String? vehicleLicensePlate,
    String? vehicleType,
    bool? isGuestVehicle,
    DateTime? createdAt,
  }) {
    return ParkingHistory(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      spotId: spotId ?? this.spotId,
      spotName: spotName ?? this.spotName,
      spotType: spotType ?? this.spotType,
      parkedAt: parkedAt ?? this.parkedAt,
      unparkedAt: unparkedAt ?? this.unparkedAt,
      duration: duration ?? this.duration,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleLicensePlate: vehicleLicensePlate ?? this.vehicleLicensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      isGuestVehicle: isGuestVehicle ?? this.isGuestVehicle,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Helper method to format duration
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  // Helper method to format date
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final parkingDate = DateTime(parkedAt.year, parkedAt.month, parkedAt.day);
    
    if (parkingDate == today) {
      return 'Today';
    } else if (parkingDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${parkedAt.day}/${parkedAt.month}/${parkedAt.year}';
    }
  }

  // Helper method to format time
  String get formattedTime {
    return '${parkedAt.hour.toString().padLeft(2, '0')}:${parkedAt.minute.toString().padLeft(2, '0')} - ${unparkedAt.hour.toString().padLeft(2, '0')}:${unparkedAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'ParkingHistory(id: $id, spotName: $spotName, duration: $formattedDuration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParkingHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
