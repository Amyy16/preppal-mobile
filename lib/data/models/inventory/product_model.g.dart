// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: json['id'] as String,
  name: json['name'] as String,
  category: $enumDecode(_$ProductCategoryEnumMap, json['category']),
  productionDate: DateTime.parse(json['production_date'] as String),
  expiryDate: DateTime.parse(json['expiry_date'] as String),
  quantityAvailable: (json['quantity_available'] as num).toDouble(),
  unit: $enumDecode(_$ProductUnitEnumMap, json['unit']),
  lowStockThreshold: (json['low_stock_threshold'] as num?)?.toDouble(),
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': _$ProductCategoryEnumMap[instance.category]!,
      'production_date': instance.productionDate.toIso8601String(),
      'expiry_date': instance.expiryDate.toIso8601String(),
      'quantity_available': instance.quantityAvailable,
      'unit': _$ProductUnitEnumMap[instance.unit]!,
      'low_stock_threshold': instance.lowStockThreshold,
      'is_active': instance.isActive,
    };

const _$ProductCategoryEnumMap = {
  ProductCategory.beverages: 'Beverages',
  ProductCategory.dairy: 'Dairy',
  ProductCategory.snacks: 'Snacks',
  ProductCategory.produce: 'Produce',
  ProductCategory.bakery: 'Bakery',
  ProductCategory.meat: 'Meat',
  ProductCategory.spices: 'Spices',
  ProductCategory.frozen: 'Frozen',
  ProductCategory.others: 'Others',
};

const _$ProductUnitEnumMap = {
  ProductUnit.kg: 'kg',
  ProductUnit.g: 'g',
  ProductUnit.litre: 'L',
  ProductUnit.ml: 'ml',
  ProductUnit.pcs: 'pcs',
  ProductUnit.dozen: 'dozen',
};
