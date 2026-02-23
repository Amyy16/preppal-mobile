// lib/data/datasources/inventory/inventory_remote_datasource.dart
//
// Simulates API calls for inventory.
// In production, replace rootBundle.loadString with http.get/post/put/delete

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:prepal2/data/models/inventory/product_model.dart';

abstract class InventoryRemoteDataSource {
  Future<List<ProductModel>> getAllProducts();
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> deleteProduct(String productId);
}

class MockInventoryRemoteDataSource implements InventoryRemoteDataSource {
  // In-memory list acts as our mock database
  // Starts empty — gets populated from JSON on first load
  List<ProductModel> _mockDatabase = [];
  bool _initialized = false;

  // Load products from JSON file once, then use in-memory list
  Future<void> _initialize() async {
    if (_initialized) return;

    final jsonString =
        await rootBundle.loadString('assets/mock_data/products.json');

    final List<dynamic> jsonList = json.decode(jsonString);

    _mockDatabase =
        jsonList.map((j) => ProductModel.fromJson(j)).toList();

    _initialized = true;
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate latency
    await _initialize();

    // Only return active products
    return _mockDatabase.where((p) => p.isActive).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _initialize();

    // Check for duplicate name in same category
    final exists = _mockDatabase.any(
      (p) =>
          p.name.toLowerCase() ==
              product.name.toLowerCase() &&
          p.category == product.category &&
          p.isActive,
    );

    if (exists) {
      throw Exception(
          '${product.name} already exists in ${product.category.name}');
    }

    _mockDatabase.add(product);
    return product;
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index =
        _mockDatabase.indexWhere((p) => p.id == product.id);

    if (index == -1) {
      throw Exception('Product not found');
    }

    _mockDatabase[index] = product;
    return product;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index =
        _mockDatabase.indexWhere((p) => p.id == productId);

    if (index == -1) {
      throw Exception('Product not found');
    }

    // Soft delete — mark as inactive rather than removing
    _mockDatabase[index] =
        _mockDatabase[index].copyWith(isActive: false);
  }
}
