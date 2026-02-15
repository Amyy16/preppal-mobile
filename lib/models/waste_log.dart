import 'package:hive/hive.dart';

part 'waste_log.g.dart';

@HiveType(typeId: 1)
class WasteLog {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String itemName;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final double quantity;
  
  @HiveField(4)
  final String unit;
  
  @HiveField(5)
  final String reason; // Expired, Spoiled, Damaged, Over-purchased, etc.
  
  @HiveField(6)
  final double costLost;
  
  @HiveField(7)
  final DateTime dateLogged;
  
  @HiveField(8)
  final String? notes;

  WasteLog({
    required this.id,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.reason,
    required this.costLost,
    required this.dateLogged,
    this.notes,
  });

  /// Get waste reasons
  static const List<String> reasons = [
    'Expired',
    'Spoiled',
    'Damaged',
    'Over-purchased',
    'Accidentally thrown',
    'Poor quality',
    'Other',
  ];

  /// Create from JSON
  factory WasteLog.fromJson(Map<String, dynamic> json) {
    return WasteLog(
      id: json['id'] ?? '',
      itemName: json['itemName'] ?? '',
      category: json['category'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      reason: json['reason'] ?? 'Other',
      costLost: (json['costLost'] ?? 0).toDouble(),
      dateLogged: DateTime.parse(json['dateLogged'] ?? DateTime.now().toString()),
      notes: json['notes'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'reason': reason,
      'costLost': costLost,
      'dateLogged': dateLogged.toString(),
      'notes': notes,
    };
  }
}
