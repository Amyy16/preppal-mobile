import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/waste_log.dart';

class WasteScreen extends StatefulWidget {
  const WasteScreen({super.key});

  @override
  State<WasteScreen> createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen> {
  late List<WasteLog> _wasteLogs = [];

  @override
  void initState() {
    super.initState();
    _loadWasteLogs();
  }

  void _loadWasteLogs() {
    // TODO: Load from Hive database
    setState(() {
      _wasteLogs = [];
    });
  }

  void _navigateToAddWaste() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddWasteScreen()),
    );
    if (result == true) {
      _loadWasteLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWaste = _wasteLogs.fold<double>(0, (sum, log) => sum + log.costLost);
    final totalItems = _wasteLogs.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Waste Log'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: _wasteLogs.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Statistics
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Items',
                        totalItems.toString(),
                        Icons.scale,
                        const Color(0xFFE53935),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Cost Lost',
                        '\$${totalWaste.toStringAsFixed(2)}',
                        Icons.attach_money,
                        const Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Waste logs
                ...(_wasteLogs.map((log) => _buildWasteCard(log))),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddWaste,
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Waste Logged',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Log wasted food to track your losses',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddWaste,
            icon: const Icon(Icons.add),
            label: const Text('Log Waste'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteCard(WasteLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFE53935).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.delete_outline, color: Color(0xFFE53935)),
          ),
        ),
        title: Text(
          log.itemName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${log.quantity} ${log.unit} • ${log.category}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.reason,
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${log.costLost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: Delete from database
                _loadWasteLogs();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddWasteScreen extends StatefulWidget {
  const AddWasteScreen({super.key});

  @override
  State<AddWasteScreen> createState() => _AddWasteScreenState();
}

class _AddWasteScreenState extends State<AddWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _itemNameController;
  late TextEditingController _quantityController;
  late TextEditingController _costLostController;
  late TextEditingController _notesController;

  String _selectedCategory = 'Vegetables';
  String _selectedUnit = 'kg';
  String _selectedReason = 'Expired';

  static const List<String> categories = ['Vegetables', 'Fruits', 'Dairy', 'Meat', 'Bakery', 'Beverages', 'Other'];
  static const List<String> units = ['kg', 'g', 'liter', 'ml', 'piece', 'dozen', 'box'];

  @override
  void initState() {
    super.initState();
    _itemNameController = TextEditingController();
    _quantityController = TextEditingController();
    _costLostController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _quantityController.dispose();
    _costLostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final wasteLog = WasteLog(
      id: const Uuid().v4(),
      itemName: _itemNameController.text.trim(),
      category: _selectedCategory,
      quantity: double.parse(_quantityController.text),
      unit: _selectedUnit,
      reason: _selectedReason,
      costLost: double.parse(_costLostController.text),
      dateLogged: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    // TODO: Save to Hive database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Waste logged!')),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Waste'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _itemNameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g., Expired Milk',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Enter item name' : null,
              ),
              const SizedBox(height: 16),

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
                        if (double.tryParse(v) == null) return 'Invalid';
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

              DropdownButtonFormField(
                value: _selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: WasteLog.reasons.map((reason) => DropdownMenuItem(value: reason, child: Text(reason))).toList(),
                onChanged: (value) => setState(() => _selectedReason = value ?? 'Expired'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _costLostController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost Lost (\$)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Additional details',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submit,
                child: const Text(
                  'Log Waste',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
