import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class ImpactScreen extends StatefulWidget {
  const ImpactScreen({super.key});

  @override
  State<ImpactScreen> createState() => _ImpactScreenState();
}

class _ImpactScreenState extends State<ImpactScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getImpactStats();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalPortions = _stats?['totalPortionsSaved'] ?? 0;
    final totalUsers = _stats?['totalUsers'] ?? 0;
    final foodSavedKg = _stats?['foodSavedKg'] ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Our Impact',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          _ImpactCard(
            icon: Icons.restaurant,
            title: 'Portions Saved',
            value: totalPortions.toString(),
            subtitle: 'Meals rescued from waste',
            color: Colors.green,
          ),
          const SizedBox(height: 20),
          _ImpactCard(
            icon: Icons.eco,
            title: 'Food Saved',
            value: '${foodSavedKg.toStringAsFixed(1)} kg',
            subtitle: 'Estimated food waste prevented',
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          _ImpactCard(
            icon: Icons.people,
            title: 'Active Users',
            value: totalUsers.toString(),
            subtitle: 'People making a difference',
            color: Colors.orange,
          ),
          const SizedBox(height: 32),
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.celebration,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Together, we\'re making a difference!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Every portion saved helps reduce food waste and feed those in need.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _ImpactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

