# Setup Guide - Campus Food Waste Connector

## Step-by-Step Setup Instructions

### 1. Prerequisites
- Flutter SDK 3.10.0 or higher installed
- Android Studio or VS Code with Flutter extensions
- A Firebase account (free tier is sufficient)

### 2. Firebase Project Setup

#### Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: "Campus Food Waste Connector" (or any name)
4. Disable Google Analytics (optional, for simplicity)
5. Click "Create project"

#### Enable Authentication
1. In Firebase Console, go to **Authentication** > **Get started**
2. Click on **Sign-in method** tab
3. Enable **Email/Password** provider
4. Click **Save**

#### Create Firestore Database
1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose a location (closest to your region)
5. Click **Enable**

#### Add Android App to Firebase
1. In Firebase Console, click the Android icon (or go to Project Settings)
2. Register your app:
   - **Android package name**: Check `android/app/build.gradle.kts` for `applicationId` (usually `com.example.project`)
   - **App nickname**: "Campus Food Waste Connector"
   - **Debug signing certificate SHA-1**: Optional for now
3. Click **Register app**
4. Download `google-services.json`
5. Place the file in: `android/app/google-services.json`

### 3. Update Android Configuration

#### Update build.gradle files

**android/build.gradle.kts** (project level):
```kotlin
buildscript {
    dependencies {
        // Add this line if not present
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

**android/app/build.gradle.kts** (app level):
Add at the bottom of the file:
```kotlin
apply plugin: 'com.google.gms.google-services'
```

Also ensure minimum SDK is 21 or higher:
```kotlin
android {
    defaultConfig {
        minSdk = 21
    }
}
```

### 4. Install Dependencies

Open terminal in the project directory and run:
```bash
cd F:\flutterproject\project
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

Or use Android Studio/VS Code to run the app.

## Testing the App

### Create Test Accounts

1. **Student Account**:
   - Email: student@test.com
   - Password: test123456
   - Role: Student
   - Student ID: TEST001

2. **Cafeteria Account**:
   - Email: cafeteria@test.com
   - Password: test123456
   - Role: Cafeteria
   - Organization: Main Cafeteria

3. **NGO Account**:
   - Email: ngo@test.com
   - Password: test123456
   - Role: NGO
   - Organization: Food Bank NGO

### Test Flow

1. **Cafeteria Flow**:
   - Login as cafeteria
   - Create a surplus post (e.g., "Vegetable Curry", 10 portions)
   - Note the post appears in the dashboard

2. **Student Flow**:
   - Login as student
   - Browse available surplus food
   - Reserve 1-2 portions
   - View QR code in "My Reservations"

3. **QR Pickup Flow**:
   - Login as cafeteria
   - Go to "Scan QR" screen
   - Scan the QR code from student's reservation
   - Confirm pickup
   - Points should be awarded to both student and cafeteria

4. **Leaderboard**:
   - Check leaderboard to see points
   - View impact statistics

## Firestore Security Rules (Production)

For production, update Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read their own data, write their own data
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Surplus posts: anyone authenticated can read, only cafeterias can create
    match /surplus_posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        resource.data.cafeteriaId == request.auth.uid;
    }
    
    // Reservations: students can create, cafeterias can update
    match /reservations/{reservationId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

## Troubleshooting

### Firebase Not Initialized Error
- Ensure `google-services.json` is in `android/app/` directory
- Run `flutter clean` and `flutter pub get`
- Rebuild the app

### Authentication Errors
- Check that Email/Password is enabled in Firebase Console
- Verify the email format is correct

### Firestore Errors
- Ensure Firestore is created and enabled
- Check security rules (use test mode for development)

### QR Scanner Not Working
- Ensure camera permissions are granted
- Check that `mobile_scanner` package is properly installed

### Build Errors
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Rebuild the app

## Next Steps

1. Customize the app theme and colors
2. Add your own logo and branding
3. Configure push notifications (optional)
4. Set up proper Firestore security rules for production
5. Test on a physical device for QR scanning
6. Add image upload functionality for food posts

## Support

For issues or questions, refer to:
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)

