import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/surplus_post_model.dart';
import '../services/firestore_service.dart';

class SurplusProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<SurplusPostModel> _activePosts = [];
  bool _isLoading = false;
  StreamSubscription<List<SurplusPostModel>>? _postsSubscription;

  List<SurplusPostModel> get activePosts => _activePosts;
  bool get isLoading => _isLoading;

  SurplusProvider() {
    // Don't load immediately - wait until needed
  }

  void loadActivePosts() {
    if (_postsSubscription != null) {
      return; // Already loading
    }

    try {
      _postsSubscription?.cancel(); // Cancel previous if any
      _postsSubscription = _firestoreService.getActiveSurplusPosts().listen(
        (posts) {
          _activePosts = posts;
          notifyListeners();
        },
        onError: (error) {
          print('Error loading posts: $error');
          _activePosts = [];
          notifyListeners();
        },
      );
    } catch (e) {
      print('Error setting up posts stream: $e');
      _activePosts = [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  Future<void> createPost(SurplusPostModel post) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _firestoreService.createSurplusPost(post);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error creating post: $e');
      rethrow;
    }
  }

  Future<void> updatePost(SurplusPostModel post) async {
    try {
      await _firestoreService.updateSurplusPost(post);
    } catch (e) {
      print('Error updating post: $e');
      rethrow;
    }
  }
}

