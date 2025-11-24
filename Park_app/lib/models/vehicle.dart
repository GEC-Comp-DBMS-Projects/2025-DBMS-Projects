class Vehicle {
  final String id;
  final String name;
  final String licensePlate;
  final String type; // 'car', 'motorcycle', 'truck', etc.
  final String color;
  final String make;
  final String model;
  final int year;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.name,
    required this.licensePlate,
    required this.type,
    required this.color,
    required this.make,
    required this.model,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert Vehicle to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'licensePlate': licensePlate,
      'type': type,
      'color': color,
      'make': make,
      'model': model,
      'year': year,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create Vehicle from Map (from Firestore)
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      type: map['type'] ?? '',
      color: map['color'] ?? '',
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Create a copy of Vehicle with updated fields
  Vehicle copyWith({
    String? id,
    String? name,
    String? licensePlate,
    String? type,
    String? color,
    String? make,
    String? model,
    int? year,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      color: color ?? this.color,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, name: $name, licensePlate: $licensePlate, type: $type, color: $color, make: $make, model: $model, year: $year)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Vehicle && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
