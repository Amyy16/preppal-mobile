import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_screen.dart';
import '../settings/settings_screen.dart';
import 'inventory_screen.dart';
import 'waste_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PrePal Dashboard'),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              // Logout
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('isLoggedIn');
              } catch (_) {}
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              const Padding(
                padding: EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ),

              // Statistics section
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Items',
                      value: '0',
                      icon: Icons.inventory_2,
                      color: const Color(0xFFFFC107),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Waste',
                      value: '0 kg',
                      icon: Icons.delete_outline,
                      color: const Color(0xFFE53935),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Saved',
                      value: '\$0',
                      icon: Icons.attach_money,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'This Week',
                      value: '0%',
                      icon: Icons.trending_down,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Activities section
              const Text(
                'Activities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 16),

              // Activity cards
              _ActivityCard(
                icon: Icons.add_circle_outline,
                title: 'Add Inventory Item',
                subtitle: 'Add a new food item to track',
                color: const Color(0xFFFFC107),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InventoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActivityCard(
                icon: Icons.inventory_2,
                title: 'View Inventory',
                subtitle: 'Check all tracked food items',
                color: const Color(0xFF2196F3),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InventoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActivityCard(
                icon: Icons.delete_outline,
                title: 'Log Waste',
                subtitle: 'Record wasted food and reasons',
                color: const Color(0xFFE53935),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const WasteScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActivityCard(
                icon: Icons.bar_chart,
                title: 'View Analytics',
                subtitle: 'See statistics and trends',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Analytics - Coming Soon')),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActivityCard(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'Manage your account and preferences',
                color: const Color(0xFF9C27B0),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),

              _ActivityCard(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
                color: const Color(0xFF607D8B),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming Soon: Help & Support')),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
