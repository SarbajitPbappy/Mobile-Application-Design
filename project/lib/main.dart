import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/surplus_provider.dart';
import 'providers/reservation_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: You need to add your Firebase configuration files
  // For now, we'll handle the case where Firebase might not be initialized
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 5),
    );
    print('Firebase initialized successfully');
  } on TimeoutException {
    print('Firebase initialization timeout');
  } catch (e) {
    print('Firebase initialization error: $e');
    print('Please add your Firebase configuration files (google-services.json)');
    // Continue anyway - app will show error screens if Firebase is needed
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SurplusProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
      ],
      child: MaterialApp(
        title: 'Campus Food Waste Connector',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Color(AppConstants.primaryColorValue),
            primary: Color(AppConstants.primaryColorValue),
            secondary: Color(AppConstants.secondaryColorValue),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
