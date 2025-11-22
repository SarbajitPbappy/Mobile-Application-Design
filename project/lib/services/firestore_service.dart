import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/surplus_post_model.dart';
import '../models/reservation_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;

  FirebaseFirestore get _firestoreInstance {
    try {
      return _firestore ??= FirebaseFirestore.instance;
    } catch (e) {
      throw Exception('Firebase not initialized. Please call Firebase.initializeApp() first.');
    }
  }

  // Surplus Posts
  Stream<List<SurplusPostModel>> getActiveSurplusPosts() {
    return _firestoreInstance
        .collection(AppConstants.surplusPostsCollection)
        .where('status', whereIn: ['active', 'partiallyReserved'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SurplusPostModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .where((post) => !post.isExpired)
            .toList());
  }

  Stream<List<SurplusPostModel>> getSurplusPostsByCafeteria(String cafeteriaId) {
    return _firestoreInstance
        .collection(AppConstants.surplusPostsCollection)
        .where('cafeteriaId', isEqualTo: cafeteriaId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SurplusPostModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<SurplusPostModel>> getBulkSurplusPosts() {
    return _firestoreInstance
        .collection(AppConstants.surplusPostsCollection)
        .where('forNgo', isEqualTo: true)
        .where('availablePortions', isGreaterThan: AppConstants.ngoBulkThreshold)
        .where('status', whereIn: ['active', 'partiallyReserved'])
        .orderBy('availablePortions', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SurplusPostModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .where((post) => !post.isExpired)
            .toList());
  }

  Future<void> createSurplusPost(SurplusPostModel post) async {
    try {
      await _firestoreInstance
          .collection(AppConstants.surplusPostsCollection)
          .doc(post.id)
          .set(post.toMap());
    } catch (e) {
      print('Error creating surplus post: $e');
      rethrow;
    }
  }

  Future<void> updateSurplusPost(SurplusPostModel post) async {
    try {
      await _firestoreInstance
          .collection(AppConstants.surplusPostsCollection)
          .doc(post.id)
          .update(post.toMap());
    } catch (e) {
      print('Error updating surplus post: $e');
      rethrow;
    }
  }

  Future<SurplusPostModel?> getSurplusPost(String postId) async {
    try {
      final doc = await _firestoreInstance
          .collection(AppConstants.surplusPostsCollection)
          .doc(postId)
          .get();
      
      if (doc.exists) {
        return SurplusPostModel.fromMap({
          'id': doc.id,
          ...doc.data()!,
        });
      }
      return null;
    } catch (e) {
      print('Error getting surplus post: $e');
      return null;
    }
  }

  // Reservations
  Stream<List<ReservationModel>> getReservationsByStudent(String studentId) {
    return _firestoreInstance
        .collection(AppConstants.reservationsCollection)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Stream<List<ReservationModel>> getReservationsByPost(String postId) {
    return _firestoreInstance
        .collection(AppConstants.reservationsCollection)
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromMap({
                  'id': doc.id,
                  ...doc.data(),
                }))
            .toList());
  }

  Future<void> createReservation(ReservationModel reservation) async {
    try {
      await _firestoreInstance
          .collection(AppConstants.reservationsCollection)
          .doc(reservation.id)
          .set(reservation.toMap());
    } catch (e) {
      print('Error creating reservation: $e');
      rethrow;
    }
  }

  Future<void> updateReservation(ReservationModel reservation) async {
    try {
      await _firestoreInstance
          .collection(AppConstants.reservationsCollection)
          .doc(reservation.id)
          .update(reservation.toMap());
    } catch (e) {
      print('Error updating reservation: $e');
      rethrow;
    }
  }

  Future<ReservationModel?> getReservationByQrCode(String qrCodeData) async {
    try {
      final snapshot = await _firestoreInstance
          .collection(AppConstants.reservationsCollection)
          .where('qrCodeData', isEqualTo: qrCodeData)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return ReservationModel.fromMap({
          'id': doc.id,
          ...doc.data(),
        });
      }
      return null;
    } catch (e) {
      print('Error getting reservation by QR: $e');
      return null;
    }
  }

  // Leaderboard
  Stream<List<Map<String, dynamic>>> getTopStudents({int limit = 10}) {
    return _firestoreInstance
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'student')
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  Stream<List<Map<String, dynamic>>> getTopCafeterias({int limit = 10}) {
    return _firestoreInstance
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: 'cafeteria')
        .orderBy('points', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  // Stats
  Future<Map<String, dynamic>> getImpactStats() async {
    try {
      final reservationsSnapshot = await _firestoreInstance
          .collection(AppConstants.reservationsCollection)
          .where('status', isEqualTo: 'completed')
          .get();
      
      int totalPortions = 0;
      for (var doc in reservationsSnapshot.docs) {
        final quantity = doc.data()['quantity'] as num?;
        totalPortions += quantity?.toInt() ?? 0;
      }

      final usersSnapshot = await _firestoreInstance
          .collection(AppConstants.usersCollection)
          .get();

      return {
        'totalPortionsSaved': totalPortions,
        'totalUsers': usersSnapshot.docs.length,
        'foodSavedKg': totalPortions * AppConstants.kgPerPortion,
      };
    } catch (e) {
      print('Error getting impact stats: $e');
      return {
        'totalPortionsSaved': 0,
        'totalUsers': 0,
        'foodSavedKg': 0.0,
      };
    }
  }
}

