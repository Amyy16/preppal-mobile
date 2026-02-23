// lib/data/models/inventory/product_model.dart
//
// Represents a single inventory product.
// Combined Model + Entity approach (same as UserModel).

import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

// All available product categories (from wireframe dropdown)
enum ProductCategory {
  @JsonValue('Beverages') beverages,
  @JsonValue('Dairy') dairy,
  @JsonValue('Snacks') snacks,
  @JsonValue('Produce') produce,
  @JsonValue('Bakery') bakery,
  @JsonValue('Meat') meat,
  @JsonValue('Spices') spices,
  @JsonValue('Frozen') frozen,
  @JsonValue('Others') others,
}

// Units of measurement
enum ProductUnit {
  @JsonValue('kg') kg,
  @JsonValue('g') g,
  @JsonValue('L') litre,
  @JsonValue('ml') ml,
  @JsonValue('pcs') pcs,
  @JsonValue('dozen') dozen,
}

@JsonSerializable()
class ProductModel {
  final String id;
  final String name;
  final ProductCategory category;

  @JsonKey(name: 'production_date')
  final DateTime productionDate;

  @JsonKey(name: 'expiry_date')
  final DateTime expiryDate;

  @JsonKey(name: 'quantity_available')
  final double quantityAvailable;

  final ProductUnit unit;

  // Low stock threshold — user defined per product
  // If null, falls back to the global fixed threshold (10)
  @JsonKey(name: 'low_stock_threshold')
  final double? lowStockThreshold;

  // Soft delete — removes from view without deleting from "DB"
  @JsonKey(name: 'is_active')
  final bool isActive;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.productionDate,
    required this.expiryDate,
    required this.quantityAvailable,
    required this.unit,
    this.lowStockThreshold,
    this.isActive = true,
  });

  // --- Computed Properties (no JSON, derived from data) ---

  // Uses user-defined threshold if set, otherwise falls back to 10
  double get effectiveThreshold => lowStockThreshold ?? 10;

  bool get isLowStock => quantityAvailable <= effectiveThreshold;

  bool get isExpired => expiryDate.isBefore(DateTime.now());

  bool get isExpiringSoon {
    final daysUntilExpiry =
        expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3 && daysUntilExpiry >= 0;
  }

  // copyWith — creates a modified copy of this product
  // Used when updating a product (immutability pattern)
  ProductModel copyWith({
    String? id,
    String? name,
    ProductCategory? category,
    DateTime? productionDate,
    DateTime? expiryDate,
    double? quantityAvailable,
    ProductUnit? unit,
    double? lowStockThreshold,
    bool? isActive,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      productionDate: productionDate ?? this.productionDate,
      expiryDate: expiryDate ?? this.expiryDate,
      quantityAvailable:
          quantityAvailable ?? this.quantityAvailable,
      unit: unit ?? this.unit,
      lowStockThreshold:
          lowStockThreshold ?? this.lowStockThreshold,
      isActive: isActive ?? this.isActive,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() =>
      _$ProductModelToJson(this);
}
