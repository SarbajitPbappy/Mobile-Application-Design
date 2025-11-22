import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../student/student_home_screen.dart';
import '../cafeteria/cafeteria_dashboard_screen.dart';
import '../ngo/ngo_home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;

  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentIdController = TextEditingController();
  final _departmentController = TextEditingController();
  final _organizationController = TextEditingController();
  final _locationController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentIdController.dispose();
    _departmentController.dispose();
    _organizationController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final user = UserModel(
      id: '', // Will be set after registration
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: widget.role,
      studentId: widget.role == UserRole.student
          ? _studentIdController.text.trim()
          : null,
      department: widget.role == UserRole.student
          ? _departmentController.text.trim()
          : null,
      organizationName: (widget.role == UserRole.cafeteria ||
              widget.role == UserRole.ngo)
          ? _organizationController.text.trim()
          : null,
      location: _locationController.text.trim().isNotEmpty
          ? _locationController.text.trim()
          : null,
      points: 0,
      createdAt: DateTime.now(),
      isVerified: false,
    );

    final success = await authProvider.register(
      _emailController.text.trim(),
      _passwordController.text,
      user,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _getHomeScreenForRole(widget.role),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed. Please try again.'),
        ),
      );
    }
  }

  Widget _getHomeScreenForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return const StudentHomeScreen();
      case UserRole.cafeteria:
        return const CafeteriaDashboardScreen();
      case UserRole.ngo:
        return const NgoHomeScreen();
      default:
        return const StudentHomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register as ${_getRoleName(widget.role)}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (widget.role == UserRole.student) ...[
                TextFormField(
                  controller: _studentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _departmentController,
                  decoration: const InputDecoration(
                    labelText: 'Department (Optional)',
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (widget.role == UserRole.cafeteria ||
                  widget.role == UserRole.ngo) ...[
                TextFormField(
                  controller: _organizationController,
                  decoration: InputDecoration(
                    labelText: widget.role == UserRole.cafeteria
                        ? 'Cafeteria Name'
                        : 'NGO Name',
                    prefixIcon: const Icon(Icons.business),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter organization name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location (Optional)',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return ElevatedButton(
                    onPressed:
                        authProvider.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Register'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRoleName(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.cafeteria:
        return 'Cafeteria';
      case UserRole.ngo:
        return 'NGO';
      default:
        return 'User';
    }
  }
}

