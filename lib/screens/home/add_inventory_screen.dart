import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/inventory_item.dart';

class AddInventoryScreen extends StatefulWidget {
  final InventoryItem? item;

  const AddInventoryScreen({super.key, this.item});

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _costPerUnitController;
  late TextEditingController _notesController;

  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'kg';
  DateTime _selectedExpiryDate = DateTime.now().add(const Duration(days: 7));

  static const List<String> categories = ['Vegetables', 'Fruits', 'Dairy', 'Meat', 'Bakery', 'Beverages', 'Other'];
  static const List<String> units = ['kg', 'g', 'liter', 'ml', 'piece', 'dozen', 'box'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _quantityController = TextEditingController(text: widget.item?.quantity.toString() ?? '');
    _costPerUnitController = TextEditingController(text: widget.item?.costPerUnit.toString() ?? '');
    _notesController = TextEditingController(text: widget.item?.notes ?? '');
    _selectedCategory = widget.item?.category ?? 'Vegetables';
    _selectedUnit = widget.item?.unit ?? 'kg';
    _selectedExpiryDate = widget.item?.expiryDate ?? DateTime.now().add(const Duration(days: 7));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costPerUnitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final item = InventoryItem(
      id: widget.item?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      quantity: double.parse(_quantityController.text),
      unit: _selectedUnit,
      expiryDate: _selectedExpiryDate,
      dateAdded: widget.item?.dateAdded ?? DateTime.now(),
      costPerUnit: double.parse(_costPerUnitController.text),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    final box = Hive.box<InventoryItem>('inventory');
    if (widget.item == null) {
      await box.add(item);
    } else {
      final key = box.keys.firstWhere(
        (key) => box.get(key)?.id == widget.item!.id,
        orElse: () => null,
      );
      if (key != null) {
        await box.put(key, item);
      }
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.item == null ? 'Item added!' : 'Item updated!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Item' : 'Edit Item'),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Item Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g., Tomatoes, Milk',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter item name' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (value) => setState(() => _selectedCategory = value ?? 'Vegetables'),
              ),
              const SizedBox(height: 16),

              // Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.scale),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                      onChanged: (value) => setState(() => _selectedUnit = value ?? 'kg'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Cost per Unit
              TextFormField(
                controller: _costPerUnitController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost per Unit (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expiry Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(_selectedExpiryDate)),
                leading: const Icon(Icons.calendar_today),
                onTap: _selectExpiryDate,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'e.g., Storage location, special care instructions',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Total Cost Display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF4CAF50)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Cost',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${_calculateTotalCost().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submit,
                child: Text(
                  widget.item == null ? 'Add Item' : 'Update Item',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotalCost() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final costPerUnit = double.tryParse(_costPerUnitController.text) ?? 0;
    return quantity * costPerUnit;
  }
}
