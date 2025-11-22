import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/reservation_provider.dart';
import '../../models/reservation_model.dart';
import '../../services/firestore_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
    });

    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);
    final firestoreService = FirestoreService();

    try {
      final reservation =
          await reservationProvider.getReservationByQrCode(barcode.rawValue!);

      if (!mounted) return;

      if (reservation == null) {
        _showError('Invalid QR code');
        return;
      }

      if (reservation.status == ReservationStatus.completed) {
        _showError('This reservation has already been completed');
        return;
      }

      if (reservation.status == ReservationStatus.cancelled ||
          reservation.status == ReservationStatus.expired) {
        _showError('This reservation is no longer valid');
        return;
      }

      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Pickup'),
          content: Text(
            'Complete reservation for ${reservation.quantity} portion(s)?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final success = await reservationProvider.completeReservation(reservation);

        if (!mounted) return;

        if (success) {
          _showSuccess('Reservation completed successfully!');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          _showError('Failed to complete reservation');
        }
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

