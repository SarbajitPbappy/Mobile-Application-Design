# Firebase Web Setup Guide

## Quick Setup Steps

### 1. Get Your Firebase Web Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Click the **gear icon** ⚙️ next to "Project Overview"
4. Select **Project Settings**
5. Scroll down to **Your apps** section
6. If you don't have a web app, click **Add app** and select **Web** (</> icon)
7. Register your app (you can skip the hosting setup for now)
8. Copy the `firebaseConfig` object

### 2. Update `web/index.html`

Open `web/index.html` and replace the placeholder values in the `firebaseConfig` object:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",                    // Your actual API key
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef"
};
```

### 3. Enable Firebase Services

In Firebase Console, make sure these are enabled:

- **Authentication** → Enable **Email/Password** sign-in method
- **Firestore Database** → Create database (start in test mode for development)

### 4. Run the App

```bash
flutter run -d chrome
```

## Alternative: Use Firebase Options (Recommended for Production)

For a more secure approach, you can use `firebase_options.dart`:

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
flutterfire configure
```

3. This will create `lib/firebase_options.dart` automatically

4. Update `main.dart`:
```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

## Troubleshooting

### Error: "FirebaseOptions cannot be null"
- Make sure you've added the Firebase config to `web/index.html`
- Check that all values in `firebaseConfig` are replaced (not "YOUR_...")
- Verify the Firebase SDK scripts are loaded before the config

### Error: "Firebase App already initialized"
- This means Firebase was initialized twice
- Check that you're not calling `Firebase.initializeApp()` multiple times

### For Android Only
- Make sure `google-services.json` is in `android/app/` directory
- The Android setup is separate from web setup

## Testing

After setup, the app should:
1. Load without Firebase errors
2. Show the role selection screen
3. Allow registration and login
4. Connect to Firestore database

