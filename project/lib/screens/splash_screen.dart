import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import 'role_selection_screen.dart';
import 'student/student_home_screen.dart';
import 'cafeteria/cafeteria_dashboard_screen.dart';
import 'ngo/ngo_home_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a bit for Firebase to initialize
    await Future.delayed(const Duration(seconds: 1));
    
    if (!mounted) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Wait for auth state to be determined (with timeout)
      int attempts = 0;
      while (authProvider.currentUser == null && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
        if (!mounted) return;
      }
      
      if (!mounted) return;
      
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        final role = authProvider.currentUser!.role;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => _getHomeScreenForRole(role),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
        );
      }
    } catch (e) {
      print('Error checking auth status: $e');
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
      );
    }
  }

  Widget _getHomeScreenForRole(role) {
    switch (role) {
      case UserRole.student:
        return const StudentHomeScreen();
      case UserRole.cafeteria:
        return const CafeteriaDashboardScreen();
      case UserRole.ngo:
        return const NgoHomeScreen();
      default:
        return const RoleSelectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'Campus Food Waste Connector',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

