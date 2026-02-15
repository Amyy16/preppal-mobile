class InventoryItem {
  final String id;
  final String name;
  final String category;
  final double quantity;
  final String unit; // kg, liter, piece, etc.
  final DateTime expiryDate;
  final DateTime dateAdded;
  final double costPerUnit;
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
