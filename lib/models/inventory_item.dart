import 'package:hive/hive.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 0)
class InventoryItem {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String category;
  
  @HiveField(3)
  final double quantity;
  
  @HiveField(4)
  final String unit; // kg, liter, piece, etc.
  
  @HiveField(5)
  final DateTime expiryDate;
  
  @HiveField(6)
  final DateTime dateAdded;
  
  @HiveField(7)
  final double costPerUnit;
  
  @HiveField(8)
  final String? notes;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.expiryDate,
    required this.dateAdded,
    required this.costPerUnit,
    this.notes,
  });

  /// Check if item is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiryDate);
  }

  /// Days until expiry
  int get daysUntilExpiry {
    return expiryDate.difference(DateTime.now()).inDays;
  }

  /// Total cost
  double get totalCost {
    return quantity * costPerUnit;
  }

  /// Create from JSON
  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toString()),
      dateAdded: DateTime.parse(json['dateAdded'] ?? DateTime.now().toString()),
      costPerUnit: (json['costPerUnit'] ?? 0).toDouble(),
      notes: json['notes'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expiryDate': expiryDate.toString(),
      'dateAdded': dateAdded.toString(),
      'costPerUnit': costPerUnit,
      'notes': notes,
    };
  }
}
