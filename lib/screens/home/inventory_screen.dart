import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/inventory_item.dart';
import 'add_inventory_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late List<InventoryItem> _items = [];
  String _filterCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    final box = Hive.box<InventoryItem>('inventory');
    setState(() {
      _items = box.values.toList();
    });
  }

  void _navigateToAddItem() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddInventoryScreen()),
    );
    if (result == true) {
      _loadItems();
    }
  }

  void _deleteItem(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final box = Hive.box<InventoryItem>('inventory');
              final key = box.keys.firstWhere(
                (key) => box.get(key)?.id == item.id,
                orElse: () => null,
              );
              if (key != null) {
                await box.delete(key);
              }
              if (mounted) {
                Navigator.pop(context);
                _loadItems();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filterCategory == 'All'
        ? _items
        : _items.where((item) => item.category == _filterCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black),
            onPressed: _navigateToAddItem,
          ),
        ],
      ),
      body: filteredItems.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Statistics
                _buildStatistics(),
                const SizedBox(height: 20),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _filterCategory == 'All'),
                      _buildFilterChip('Vegetables', _filterCategory == 'Vegetables'),
                      _buildFilterChip('Fruits', _filterCategory == 'Fruits'),
                      _buildFilterChip('Dairy', _filterCategory == 'Dairy'),
                      _buildFilterChip('Meat', _filterCategory == 'Meat'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Items list
                ...filteredItems.map((item) => _buildItemCard(item)),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItem,
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
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
            Icons.inventory_2,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No Items Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add food items to track your inventory',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC107),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    final totalItems = _items.length;
    final totalCost = _items.fold(0.0, (sum, item) => sum + item.totalCost);
    final expiringSoon = _items.where((item) => item.daysUntilExpiry <= 3 && item.daysUntilExpiry >= 0).length;
    final expired = _items.where((item) => item.isExpired).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Items', totalItems.toString(), Icons.inventory_2, const Color(0xFFFFC107)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Total Value', '\$${totalCost.toStringAsFixed(2)}', Icons.attach_money, const Color(0xFF4CAF50)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Expiring', expiringSoon.toString(), Icons.schedule, const Color(0xFFF57C00)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard('Expired', expired.toString(), Icons.warning, const Color(0xFFE53935)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (value) {
          setState(() {
            _filterCategory = label;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: const Color(0xFFFFC107),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildItemCard(InventoryItem item) {
    final daysLeft = item.daysUntilExpiry;
    Color statusColor = Colors.green;
    String statusText = '$daysLeft days left';

    if (item.isExpired) {
      statusColor = const Color(0xFFE53935);
      statusText = 'Expired';
    } else if (daysLeft <= 3) {
      statusColor = const Color(0xFFF57C00);
      statusText = 'Expiring soon!';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              item.name[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFC107),
              ),
            ),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${item.quantity} ${item.unit} • ${item.category}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${item.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () {
                // TODO: Implement edit functionality
              },
            ),
            PopupMenuItem(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () => _deleteItem(item),
            ),
          ],
        ),
      ),
    );
  }
}
