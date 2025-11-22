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
  
  // Initialize Firebase for Android
  // Make sure google-services.json is in android/app/ directory
  try {
    await Firebase.initializeApp().timeout(
      const Duration(seconds: 10),
    );
    print('✅ Firebase initialized successfully');
  } on TimeoutException {
    print('❌ Firebase initialization timeout');
    print('Please check:');
    print('1. google-services.json is in android/app/ directory');
    print('2. Google Services plugin is configured in build.gradle.kts');
    print('3. Firebase project is set up correctly');
  } catch (e) {
    print('❌ Firebase initialization error: $e');
    print('');
    print('SETUP REQUIRED for Android:');
    print('1. Download google-services.json from Firebase Console');
    print('2. Place it in android/app/ directory');
    print('3. Ensure build.gradle.kts has Google Services plugin');
    print('4. Run: flutter clean && flutter pub get');
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
