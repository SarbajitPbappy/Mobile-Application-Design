# Android Firebase Setup Guide

## ✅ Current Status

Your `google-services.json` file is already in place at `android/app/google-services.json`.

## Configuration Steps

### 1. Verify Build Files

The build.gradle files have been configured:

**android/build.gradle.kts** (project level):
- ✅ Google Services classpath added

**android/app/build.gradle.kts** (app level):
- ✅ Google Services plugin added

### 2. Clean and Rebuild

Run these commands:

```bash
cd F:\flutterproject\project
flutter clean
flutter pub get
```

### 3. Verify Firebase Services

In [Firebase Console](https://console.firebase.google.com/):

1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable **Email/Password**

2. **Firestore Database**:
   - Go to Firestore Database
   - Create database (start in test mode for development)

### 4. Run on Android

```bash
flutter run
```

Or use Android Studio:
- Open the project
- Select an Android device/emulator
- Click Run

## Troubleshooting

### Error: "google-services.json not found"
- Ensure the file is at: `android/app/google-services.json`
- Check file name spelling (must be exactly `google-services.json`)

### Error: "Plugin with id 'com.google.gms.google-services' not found"
- Run `flutter clean`
- Run `flutter pub get`
- Rebuild the project

### Error: "FirebaseOptions cannot be null"
- Make sure `google-services.json` is valid
- Verify the package name in `google-services.json` matches `applicationId` in `build.gradle.kts`
- Current package: `com.example.project`

### Build Errors
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
flutter run
```

## Verify Configuration

Check that:
- ✅ `google-services.json` exists in `android/app/`
- ✅ `android/build.gradle.kts` has Google Services classpath
- ✅ `android/app/build.gradle.kts` has Google Services plugin
- ✅ Package name matches in both files

## Testing

After setup, the app should:
1. Initialize Firebase without errors
2. Show splash screen
3. Allow registration/login
4. Connect to Firestore

If you see Firebase initialization errors, check the console output for specific issues.

