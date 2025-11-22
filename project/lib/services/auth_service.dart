import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth get _authInstance {
    try {
      return _auth ??= FirebaseAuth.instance;
    } catch (e) {
      throw Exception('Firebase not initialized. Please call Firebase.initializeApp() first.');
    }
  }

  FirebaseFirestore get _firestoreInstance {
    try {
      return _firestore ??= FirebaseFirestore.instance;
    } catch (e) {
      throw Exception('Firebase not initialized. Please call Firebase.initializeApp() first.');
    }
  }

  User? get currentUser {
    try {
      return _authInstance.currentUser;
    } catch (e) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      return _authInstance.authStateChanges();
    } catch (e) {
      return Stream.value(null);
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestoreInstance
          .collection('users')
          .doc(userId)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _authInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  Future<UserCredential?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error registering: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestoreInstance
          .collection('users')
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestoreInstance
          .collection('users')
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authInstance.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  Future<void> updateUserPoints(String userId, int points) async {
    try {
      await _firestoreInstance
          .collection('users')
          .doc(userId)
          .update({'points': FieldValue.increment(points)});
    } catch (e) {
      print('Error updating points: $e');
      rethrow;
    }
  }
}

