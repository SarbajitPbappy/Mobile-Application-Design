import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/surplus_post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import 'student_reservations_screen.dart';

class PostDetailsScreen extends StatefulWidget {
  final SurplusPostModel post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  int _selectedQuantity = 1;
  bool _isReserving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.post.imageUrl != null)
              Image.network(
                widget.post.imageUrl!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.post.category == FoodCategory.veg
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          widget.post.category == FoodCategory.veg
                              ? 'Vegetarian'
                              : 'Non-Vegetarian',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.post.description != null &&
                      widget.post.description!.isNotEmpty)
                    Text(
                      widget.post.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 24),
                  _InfoRow(
                    icon: Icons.restaurant,
                    label: 'Available Portions',
                    value: '${widget.post.availablePortions} / ${widget.post.totalPortions}',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.location_on,
                    label: 'Pickup Location',
                    value: widget.post.pickupLocation,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Pickup Window',
                    value:
                        '${_formatDateTime(widget.post.startTime)} - ${_formatDateTime(widget.post.endTime)}',
                  ),
                  const SizedBox(height: 24),
                  if (widget.post.availablePortions > 0) ...[
                    const Text(
                      'Select Quantity:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _selectedQuantity > 1
                              ? () {
                                  setState(() {
                                    _selectedQuantity--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '$_selectedQuantity',
                          style: const TextStyle(fontSize: 24),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _selectedQuantity <
                                  widget.post.availablePortions
                              ? () {
                                  setState(() {
                                    _selectedQuantity++;
                                  });
                                }
                              : null,
                        ),
                        const Spacer(),
                        Text(
                          'Max: ${widget.post.availablePortions}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Consumer<ReservationProvider>(
                      builder: (context, reservationProvider, _) {
                        return ElevatedButton(
                          onPressed: _isReserving
                              ? null
                              : () => _handleReserve(reservationProvider),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.green,
                          ),
                          child: _isReserving
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Reserve Portion',
                                  style: TextStyle(fontSize: 18),
                                ),
                        );
                      },
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'All portions have been reserved',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Future<void> _handleReserve(ReservationProvider reservationProvider) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to reserve')),
      );
      return;
    }

    setState(() {
      _isReserving = true;
    });

    final success = await reservationProvider.createReservation(
      widget.post,
      _selectedQuantity,
      authProvider.currentUser!.id,
    );

    if (!mounted) return;

    setState(() {
      _isReserving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation successful! Check My Reservations.'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const StudentReservationsScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reservation failed. Please try again.'),
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

