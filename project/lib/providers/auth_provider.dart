import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    // Delay initialization to ensure Firebase is ready
    Future.delayed(const Duration(milliseconds: 100), () {
      try {
        _authSubscription = _authService.authStateChanges.listen(
          (User? user) async {
            if (user != null) {
              await loadUserData(user.uid);
            } else {
              _currentUser = null;
              notifyListeners();
            }
          },
          onError: (error) {
            print('Auth stream error: $error');
            notifyListeners();
          },
        );
      } catch (e) {
        print('Error initializing auth: $e');
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadUserData(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _currentUser = await _authService.getUserData(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading user data: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential?.user != null) {
        await loadUserData(userCredential!.user!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error signing in: $e');
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    UserModel user,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.registerWithEmailAndPassword(
        email,
        password,
      );

      if (userCredential?.user != null) {
        final newUser = user.copyWith(id: userCredential!.user!.uid);
        await _authService.createUserProfile(newUser);
        await loadUserData(newUser.id);
        return true;
      }
      return false;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error registering: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _authService.updateUserProfile(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}

