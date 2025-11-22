import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/reservation_model.dart';
import '../models/surplus_post_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class ReservationProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();
  
  List<ReservationModel> _reservations = [];
  bool _isLoading = false;
  StreamSubscription<List<ReservationModel>>? _reservationsSubscription;

  List<ReservationModel> get reservations => _reservations;
  bool get isLoading => _isLoading;

  ReservationProvider() {
    // Will be initialized with userId when needed
  }

  void loadReservations(String studentId) {
    _reservationsSubscription?.cancel(); // Cancel previous if any
    
    try {
      _reservationsSubscription = _firestoreService.getReservationsByStudent(studentId).listen(
        (reservations) {
          _reservations = reservations;
          notifyListeners();
        },
        onError: (error) {
          print('Error loading reservations: $error');
          _reservations = [];
          notifyListeners();
        },
      );
    } catch (e) {
      print('Error setting up reservations stream: $e');
      _reservations = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _reservationsSubscription?.cancel();
    super.dispose();
  }

  Future<bool> createReservation(
    SurplusPostModel post,
    int quantity,
    String studentId,
  ) async {
    try {
      if (quantity > post.availablePortions) {
        return false;
      }

      _isLoading = true;
      notifyListeners();

      final reservationId = _uuid.v4();
      final qrCodeData = reservationId;

      final reservation = ReservationModel(
        id: reservationId,
        postId: post.id,
        studentId: studentId,
        quantity: quantity,
        qrCodeData: qrCodeData,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createReservation(reservation);

      // Update post available portions
      final updatedPost = post.copyWith(
        availablePortions: post.availablePortions - quantity,
        status: (post.availablePortions - quantity == 0)
            ? PostStatus.fullReserved
            : PostStatus.partiallyReserved,
      );
      await _firestoreService.updateSurplusPost(updatedPost);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error creating reservation: $e');
      return false;
    }
  }

  Future<bool> completeReservation(ReservationModel reservation) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedReservation = reservation.copyWith(
        status: ReservationStatus.completed,
        completedAt: DateTime.now(),
      );

      await _firestoreService.updateReservation(updatedReservation);

      // Award points
      await _authService.updateUserPoints(
        reservation.studentId,
        AppConstants.pointsPerPickup * reservation.quantity,
      );

      // Get post to award cafeteria points
      final post = await _firestoreService.getSurplusPost(reservation.postId);
      if (post != null) {
        await _authService.updateUserPoints(
          post.cafeteriaId,
          AppConstants.pointsPerDonatedPortion * reservation.quantity,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error completing reservation: $e');
      return false;
    }
  }

  Future<ReservationModel?> getReservationByQrCode(String qrCodeData) async {
    try {
      return await _firestoreService.getReservationByQrCode(qrCodeData);
    } catch (e) {
      print('Error getting reservation by QR: $e');
      return null;
    }
  }
}

