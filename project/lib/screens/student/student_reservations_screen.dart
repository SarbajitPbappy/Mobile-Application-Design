import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/reservation_model.dart';
import 'qr_code_screen.dart';

class StudentReservationsScreen extends StatefulWidget {
  const StudentReservationsScreen({super.key});

  @override
  State<StudentReservationsScreen> createState() =>
      _StudentReservationsScreenState();
}

class _StudentReservationsScreenState extends State<StudentReservationsScreen> {
  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      reservationProvider.loadReservations(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
      ),
      body: Consumer2<AuthProvider, ReservationProvider>(
        builder: (context, authProvider, reservationProvider, _) {
          if (authProvider.currentUser == null) {
            return const Center(child: Text('Please login'));
          }

          if (reservationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final reservations = reservationProvider.reservations;

          if (reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reservations yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              return _ReservationCard(
                reservation: reservations[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (reservation.status) {
      case ReservationStatus.reserved:
        statusColor = Colors.blue;
        statusText = 'Reserved';
        statusIcon = Icons.schedule;
        break;
      case ReservationStatus.completed:
        statusColor = Colors.green;
        statusText = 'Completed';
        statusIcon = Icons.check_circle;
        break;
      case ReservationStatus.cancelled:
        statusColor = Colors.red;
        statusText = 'Cancelled';
        statusIcon = Icons.cancel;
        break;
      case ReservationStatus.expired:
        statusColor = Colors.grey;
        statusText = 'Expired';
        statusIcon = Icons.access_time;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reservation #${reservation.id.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 18,
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.restaurant, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${reservation.quantity} portion${reservation.quantity > 1 ? 's' : ''}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(reservation.createdAt),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            if (reservation.status == ReservationStatus.reserved) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QrCodeScreen(
                          reservationId: reservation.id,
                          qrCodeData: reservation.qrCodeData,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Show QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

