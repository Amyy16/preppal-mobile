import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prepal2/presentation/providers/inventory_provider.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();

    final alerts = [
      ...inventory.lowStockProducts.map((p) => _AlertItem(
            title: '${p.name} is low on stock',
            subtitle: '${p.quantityAvailable} ${p.unit.name} remaining',
            color: Colors.orange,
            icon: Icons.warning_amber,
          )),
      ...inventory.expiringSoonProducts.map((p) => _AlertItem(
            title: '${p.name} is expiring soon',
            subtitle: 'Expires ${p.expiryDate.day}-${p.expiryDate.month}-${p.expiryDate.year}',
            color: Colors.red,
            icon: Icons.schedule,
          )),
      ...inventory.expiredProducts.map((p) => _AlertItem(
            title: '${p.name} has expired',
            subtitle: 'Please remove from inventory',
            color: Colors.grey,
            icon: Icons.cancel_outlined,
          )),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        title: const Text('Alerts'),
        automaticallyImplyLeading: false,
      ),
      body: alerts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('All good! No alerts right now 🎉',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (_, i) => alerts[i],
            ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
